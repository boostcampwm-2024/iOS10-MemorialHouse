import MHFoundation
import Combine
import MHDomain
import MHCore

final class EditBookViewModel: ViewModelType {
    // MARK: - Type
    enum Input {
        case viewDidLoad
        case didAddMediaWithData(type: MediaType, data: Data)
        case didAddMediaInURL(type: MediaType, url: URL)
        case didAddMediaInTemporary(media: MediaDescription)
        case addPageButtonTapped
        case didSaveButtonTapped
        case didCancelButtonTapped
    }
    enum Output {
        case updateViewController(title: String)
        case error(message: String)
    }
    
    // MARK: - Property
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let fetchBookUseCase: FetchBookUseCase
    private let updateBookUseCase: UpdateBookUseCase
    private let storeMediaUseCase: PersistentlyStoreMediaUseCase
    private let createMediaUseCase: CreateMediaUseCase
    private let fetchMediaUseCase: FetchMediaUseCase
    private let deleteMediaUseCase: DeleteMediaUseCase
    private let bookID: UUID
    private var title: String = ""
    private var editPageViewModels: [EditPageViewModel] = []
    private var currentPageIndex = 0
    
    // MARK: - Initializer
    init(
        fetchBookUseCase: FetchBookUseCase,
        updateBookUseCase: UpdateBookUseCase,
        storeMediaUseCase: PersistentlyStoreMediaUseCase,
        createMediaUseCase: CreateMediaUseCase,
        fetchMediaUseCase: FetchMediaUseCase,
        deleteMediaUseCase: DeleteMediaUseCase,
        bookID: UUID
    ) {
        self.fetchBookUseCase = fetchBookUseCase
        self.updateBookUseCase = updateBookUseCase
        self.storeMediaUseCase = storeMediaUseCase
        self.createMediaUseCase = createMediaUseCase
        self.fetchMediaUseCase = fetchMediaUseCase
        self.deleteMediaUseCase = deleteMediaUseCase
        self.bookID = bookID
    }
    
    // MARK: - Binding Method
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                Task { await self?.fetchBook() }
            case let .didAddMediaWithData(type, data):
                Task { await self?.addMedia(type: type, with: data) }
            case let .didAddMediaInURL(type, url):
                Task { await self?.addMedia(type: type, in: url) }
            case let .didAddMediaInTemporary(media):
                Task { await self?.addMedia(media) }
            case .addPageButtonTapped:
                self?.addEmptyPage()
            case .didSaveButtonTapped:
                Task { await self?.saveMediaAll() }
            case .didCancelButtonTapped:
                Task { await self?.revokeMediaAll() }
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    private func fetchBook() async {
        do {
            let book = try await fetchBookUseCase.execute(id: bookID)
            title = book.title
            editPageViewModels = book.pages.map { page in
                let editPageViewModel = EditPageViewModel(
                    fetchMediaUseCase: fetchMediaUseCase,
                    deleteMediaUseCase: deleteMediaUseCase,
                    bookID: bookID,
                    page: page
                )
                editPageViewModel.delegate = self
                return editPageViewModel
            }
            output.send(.updateViewController(title: title))
        } catch {
            output.send(.error(message: "책을 가져오는데 실패했습니다."))
            MHLogger.error(error.localizedDescription + #function)
        }
    }
    private func addMedia(type: MediaType, with data: Data) async {
        let description = MediaDescription(
            id: UUID(),
            type: type
        )
        do {
            try await createMediaUseCase.execute(media: description, data: data, at: bookID)
            editPageViewModels[currentPageIndex].addMedia(media: description, data: data)
        } catch {
            output.send(.error(message: "미디어를 추가하는데 실패했습니다."))
            MHLogger.error(error.localizedDescription + #function)
        }
    }
    private func addMedia(type: MediaType, in url: URL) async {
        let description = MediaDescription(
            id: UUID(),
            type: type
        )
        do {
            try await createMediaUseCase.execute(media: description, from: url, at: bookID)
            editPageViewModels[currentPageIndex].addMedia(media: description, url: url)
        } catch {
            output.send(.error(message: "미디어를 추가하는데 실패했습니다."))
            MHLogger.error(error.localizedDescription + #function)
        }
    }
    private func addMedia(_ description: MediaDescription) async {
        do {
            try await storeMediaUseCase.excute(media: description, to: bookID)
            let url: URL = try await fetchMediaUseCase.execute(media: description, in: bookID)
            editPageViewModels[currentPageIndex].addMedia(media: description, url: url)
        } catch {
            output.send(.error(message: "미디어를 추가하는데 실패했습니다."))
            MHLogger.error(error.localizedDescription + #function)
        }
    }
    private func addEmptyPage() {
        let page = Page(id: UUID(), metadata: [:], text: "")
        let editPageViewModel = EditPageViewModel(
            fetchMediaUseCase: fetchMediaUseCase,
            deleteMediaUseCase: deleteMediaUseCase,
            bookID: bookID,
            page: page
        )
        editPageViewModel.delegate = self
        editPageViewModels.append(editPageViewModel)
        output.send(.updateViewController(title: title))
    }
    private func saveMediaAll() async {
        let pages = editPageViewModels.map { $0.page }
        let book = Book(id: bookID, title: title, pages: pages)
        let mediaList = pages.flatMap { $0.metadata.values }
        do {
            try await updateBookUseCase.execute(id: bookID, book: book)
            try await storeMediaUseCase.execute(to: bookID, mediaList: mediaList)
        } catch {
            output.send(.error(message: "책을 저장하는데 실패했습니다."))
            MHLogger.error(error.localizedDescription + #function)
        }
    }
    private func revokeMediaAll() async {
        do {
            try await storeMediaUseCase.execute(to: bookID, mediaList: nil)
        } catch {
            output.send(.error(message: "저장 취소하는데 실패했습니다."))
            MHLogger.error(error.localizedDescription + #function)
        }
    }
    
    // MARK: - Method For ViewController
    func numberOfPages() -> Int {
        return editPageViewModels.count
    }
    func editPageViewModel(at index: Int) -> EditPageViewModel {
        let editPageViewModel = editPageViewModels[index]
        
        return editPageViewModel
    }
}

extension EditBookViewModel: EditPageViewModelDelegate {
    func didBeginEditingPage(_ editPageViewModel: EditPageViewModel, page: Page) {
        let pageID = page.id
        currentPageIndex = editPageViewModels.firstIndex { $0.page.id == pageID } ?? 0
    }
}
