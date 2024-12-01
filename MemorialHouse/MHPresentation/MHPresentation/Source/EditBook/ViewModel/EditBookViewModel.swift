import MHFoundation
@preconcurrency import Combine
import MHDomain
import MHCore

final class EditBookViewModel: ViewModelType {
    // MARK: - Type
    enum Input {
        case viewDidLoad(bookID: UUID)
        case didSelectPage(at: Int)
        case didAddMediaWithData(type: MediaType, data: Data)
        case didAddMediaInURL(type: MediaType, url: URL)
        case addPageButtonTapped
        case didSaveButtonTapped
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
    private var bookID: UUID?
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
        deleteMediaUseCase: DeleteMediaUseCase
    ) {
        self.fetchBookUseCase = fetchBookUseCase
        self.updateBookUseCase = updateBookUseCase
        self.storeMediaUseCase = storeMediaUseCase
        self.createMediaUseCase = createMediaUseCase
        self.fetchMediaUseCase = fetchMediaUseCase
        self.deleteMediaUseCase = deleteMediaUseCase
    }
    
    // MARK: - Binding Method
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case let .viewDidLoad(bookID):
                Task { await self?.fetchBook(bookID: bookID) }
            case let .didSelectPage(at: index):
                self?.currentPageIndex = index
            case let .didAddMediaWithData(type, data):
                Task { await self?.addMedia(type: type, with: data) }
            case let .didAddMediaInURL(type, url):
                Task { await self?.addMedia(type: type, in: url) }
            case .addPageButtonTapped:
                self?.addEmptyPage()
            case .didSaveButtonTapped:
                Task { await self?.saveMediaAll() }
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    private func fetchBook(bookID: UUID) async {
        self.bookID = bookID
        do {
            let book = try await fetchBookUseCase.execute(id: bookID)
            title = book.title
            editPageViewModels = book.pages.map { page in
                EditPageViewModel(
                    fetchMediaUseCase: fetchMediaUseCase,
                    deleteMediaUseCase: deleteMediaUseCase,
                    bookID: bookID,
                    page: page
                )
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
    private func addEmptyPage() {
        guard let bookID else { return }
        let page = Page(id: UUID(), metadata: [:], text: "")
        let editPageViewModel = EditPageViewModel(
            fetchMediaUseCase: fetchMediaUseCase,
            deleteMediaUseCase: deleteMediaUseCase,
            bookID: bookID,
            page: page
        )
        editPageViewModels.append(editPageViewModel)
        output.send(.updateViewController(title: title))
    }
    private func saveMediaAll() async {
        guard let bookID else { return }
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
    
    // MARK: - Method
    func numberOfPages() -> Int {
        return editPageViewModels.count
    }
    func editPageViewModel(at index: Int) -> EditPageViewModel {
        let editPageViewModel = editPageViewModels[index]
        
        return editPageViewModel
    }
}
