import MHFoundation
import Combine
import MHDomain

final class EditBookViewModel: ViewModelType {
    // MARK: - Type
    enum Input {
        case viewDidLoad
        case didAddMediaWithData(type: MediaType, at: Int, data: Data)
        case didAddMediaInURL(type: MediaType, at: Int, url: URL)
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
    private let bookID: UUID
    private var book: Book?
    
    // MARK: - Initializer
    init(
        fetchBookUseCase: FetchBookUseCase,
        updateBookUseCase: UpdateBookUseCase,
        storeBookUseCase: PersistentlyStoreMediaUseCase,
        bookID: UUID
    ) {
        self.fetchBookUseCase = fetchBookUseCase
        self.updateBookUseCase = updateBookUseCase
        self.storeBookUseCase = storeBookUseCase
        self.bookID = bookID
    }
    
    // MARK: - Method
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                self?.fetchBook()
            case let .didAddMediaWithData(type, at, data):
                self?.addMedia(type: type, at: at, with: data)
            case let .didAddMediaInURL(type, at, url):
                self?.addMedia(type: type, at: at, in: url)
            case .didSaveButtonTapped:
                <#code#>
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    private func fetchBook() {
        Task {
            book = try await fetchBookUseCase.execute(bookID: bookID)
        }
    }
    private func addMedia(type: MediaType, at index: Int, with data: Data) {
        let description = MediaDescription(
            id: UUID(),
            type: type
        )
        
    }
    private func addMedia(type: MediaType, at index: Int, in url: URL) {
        let description = MediaDescription(
            id: UUID(),
            type: type
        )
        
    }

}
