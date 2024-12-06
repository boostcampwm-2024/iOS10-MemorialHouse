import MHFoundation
import Combine
import MHDomain
import MHCore

final class EditBookViewModel: ViewModelType {
    // MARK: - Type
    enum Input {
        case fetchBook
        case didAddMediaInTemporary(media: MediaDescription)
        case didAddMediaWithData(type: MediaType, attributes: [String: any Sendable]?, data: Data)
        case didAddMediaInURL(type: MediaType, attributes: [String: any Sendable]?, url: URL)
        case addPageButtonTapped
        case didSaveButtonTapped
        case didCancelButtonTapped
    }
    enum Output {
        case updateViewController(title: String)
        case pageAdded(at: Int)
        case saveDone
        case revokeDone
        case addableMediaTypes([MediaType])
        case error(message: String)
    }
    
    // MARK: - Property
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let fetchBookUseCase: FetchBookUseCase
    private let updateBookUseCase: UpdateBookUseCase
    private let storeMediaUseCase: PersistentlyStoreMediaUseCase
    private let deleteTemporaryMediaUsecase: DeleteTemporaryMediaUseCase
    private let createMediaUseCase: CreateMediaUseCase
    private let fetchMediaUseCase: FetchMediaUseCase
    private let deleteMediaUseCase: DeleteMediaUseCase
    private let bookID: UUID
    private let bookTitle: String
    private var editPageViewModels: [EditPageViewModel] = []
    private var currentPageIndex = 0
    
    // MARK: - Initializer
    init(
        fetchBookUseCase: FetchBookUseCase,
        updateBookUseCase: UpdateBookUseCase,
        storeMediaUseCase: PersistentlyStoreMediaUseCase,
        deleteTemporaryMediaUsecase: DeleteTemporaryMediaUseCase,
        createMediaUseCase: CreateMediaUseCase,
        fetchMediaUseCase: FetchMediaUseCase,
        deleteMediaUseCase: DeleteMediaUseCase,
        bookID: UUID,
        bookTitle: String
    ) {
        self.fetchBookUseCase = fetchBookUseCase
        self.updateBookUseCase = updateBookUseCase
        self.storeMediaUseCase = storeMediaUseCase
        self.deleteTemporaryMediaUsecase = deleteTemporaryMediaUsecase
        self.createMediaUseCase = createMediaUseCase
        self.fetchMediaUseCase = fetchMediaUseCase
        self.deleteMediaUseCase = deleteMediaUseCase
        self.bookID = bookID
        self.bookTitle = bookTitle
    }
    
    // MARK: - Binding Method
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .fetchBook:
                Task { await self?.fetchBook() }
            case let .didAddMediaInTemporary(media):
                Task { await self?.addMedia(media) }
            case let .didAddMediaWithData(type, attributes, data):
                Task { await self?.addMedia(type: type, attributes: attributes, with: data) }
            case let .didAddMediaInURL(type, attributes, url):
                Task { await self?.addMedia(type: type, attributes: attributes, in: url) }
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
            output.send(.updateViewController(title: bookTitle))
        } catch {
            output.send(.error(message: "책을 가져오는데 실패했습니다."))
            MHLogger.error(error.localizedDescription + #function)
        }
    }
    
    private func addMedia(type: MediaType, attributes: [String: any Sendable]?, with data: Data) async {
        let description = MediaDescription(type: type, attributes: attributes)
        do {
            try await createMediaUseCase.execute(media: description, data: data, at: bookID)
            editPageViewModels[currentPageIndex].addMedia(media: description, data: data)
        } catch {
            output.send(.error(message: "미디어를 추가하는데 실패했습니다."))
            MHLogger.error(error.localizedDescription + #function)
        }
    }
    
    private func addMedia(type: MediaType, attributes: [String: any Sendable]?, in url: URL) async {
        let description = MediaDescription(type: type, attributes: attributes)
        do {
            try await createMediaUseCase.execute(media: description, from: url, at: bookID)
            if type == .audio {
                try await deleteTemporaryMediaUsecase.execute(media: description)
            }
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
        let editPageViewModel = EditPageViewModel(
            fetchMediaUseCase: fetchMediaUseCase,
            deleteMediaUseCase: deleteMediaUseCase,
            bookID: bookID,
            page: Page()
        )
        editPageViewModel.delegate = self
        editPageViewModels.append(editPageViewModel)
        output.send(.pageAdded(at: editPageViewModels.count-1))
    }
    
    private func saveMediaAll() async {
        let pages = editPageViewModels.map { $0.page }
        let book = Book(id: bookID, title: bookTitle, pages: pages)
        let mediaList = pages.flatMap { $0.metadata.values }
        do {
            try await updateBookUseCase.execute(id: bookID, book: book)
            try await storeMediaUseCase.execute(to: bookID, mediaList: mediaList)
            output.send(.saveDone)
        } catch {
            output.send(.error(message: "책을 저장하는데 실패했습니다."))
            MHLogger.error(error.localizedDescription + #function)
        }
    }
    
    private func revokeMediaAll() async {
        do {
            try await storeMediaUseCase.execute(to: bookID, mediaList: nil)
            output.send(.revokeDone)
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
    
    func updateAddableMediaTypes(_ editPageViewModel: EditPageViewModel, mediaTypes: [MediaType]) {
        let pageID = editPageViewModel.page.id
        let currentPage = editPageViewModels[currentPageIndex]
        guard pageID == currentPage.page.id else { return }
        output.send(.addableMediaTypes(mediaTypes))
    }
}
