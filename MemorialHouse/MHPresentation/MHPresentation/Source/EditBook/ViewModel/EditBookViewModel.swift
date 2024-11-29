import MHFoundation
@preconcurrency import Combine
import MHDomain
import MHCore

final class EditBookViewModel: ViewModelType {
    // MARK: - Type
    enum Input {
        case viewDidLoad(bookID: UUID)
        case didAddMediaWithData(type: MediaType, atPage: Int, data: Data)
        case didAddMediaInURL(type: MediaType, atPage: Int, url: URL)
        case didSaveButtonTapped
    }
    enum Output {
        case setTableView
    }
    
    // MARK: - Property
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let fetchBookUseCase: FetchBookUseCase
    private let updateBookUseCase: UpdateBookUseCase
    private let storeBookUseCase: PersistentlyStoreMediaUseCase
    private let createMediaUseCase: CreateMediaUseCase
    private let fetchMediaUseCase: FetchMediaUseCase
    private let deleteMediaUseCase: DeleteMediaUseCase
    private var bookID: UUID?
    private var pageViewModels: [EditPageViewModel] = []
    
    // MARK: - Initializer
    init(
        fetchBookUseCase: FetchBookUseCase,
        updateBookUseCase: UpdateBookUseCase,
        storeBookUseCase: PersistentlyStoreMediaUseCase,
        createMediaUseCase: CreateMediaUseCase,
        fetchMediaUseCase: FetchMediaUseCase,
        deleteMediaUseCase: DeleteMediaUseCase
    ) {
        self.fetchBookUseCase = fetchBookUseCase
        self.updateBookUseCase = updateBookUseCase
        self.storeBookUseCase = storeBookUseCase
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
            case let .didAddMediaWithData(type, atPage, data):
                self?.addMedia(type: type, at: atPage, with: data)
            case let .didAddMediaInURL(type, atPage, url):
                self?.addMedia(type: type, at: atPage, in: url)
            case .didSaveButtonTapped:
                Task { await self?.saveMediaAll() }
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    private func fetchBook(bookID: UUID) async {
        self.bookID = bookID
        guard let book = try? await fetchBookUseCase.execute(bookID: bookID) else { return }
        book.pages.forEach { page in
            let pageViewModel = EditPageViewModel(
                createMediaUseCase: createMediaUseCase,
                fetchMediaUseCase: fetchMediaUseCase,
                deleteMediaUseCase: deleteMediaUseCase,
                bookID: bookID,
                page: page
            )
            pageViewModels.append(pageViewModel)
        }
        output.send(.setTableView)
    }
    private func addMedia(type: MediaType, at index: Int, with data: Data) {
        let description = MediaDescription(
            id: UUID(),
            type: type
        )
        pageViewModels[index].addMedia(media: description, data: data)
    }
    private func addMedia(type: MediaType, at index: Int, in url: URL) {
        let description = MediaDescription(
            id: UUID(),
            type: type
        )
        pageViewModels[index].addMedia(media: description, url: url)
    }
    private func saveMediaAll() async {
        guard let bookID else { return }
        try? await storeBookUseCase.execute(to: bookID)
    }
    
    // MARK: - Method
    func numberOfPages() -> Int {
        return pageViewModels.count
    }
    func page(at index: Int) -> EditPageViewModel {
        return pageViewModels[index]
    }
}
