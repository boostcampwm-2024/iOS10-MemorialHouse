import MHFoundation
import MHDomain
import Combine
import Photos

final class CreateBookCoverViewModel: ViewModelType {
    enum Input {
        case viewDidAppear
        case changedBookTitle(title: String?)
        case changedBookColor(colorIndex: Int)
        case changedBookCategory(category: String?)
        case saveBookCover
    }
    
    enum Output {
        case bookTitle(title: String?)
        case bookColorIndex(previousIndex: Int?, nowIndex: Int, bookColor: BookColor)
        case bookCategory(category: String?)
        case moveToNext
    }
    
    private let fetchMemorialHouseNameUseCase: FetchMemorialHouseNameUseCase
    private let createBookCoverUseCase: CreateBookCoverUseCase
    private let deleteBookCoverUseCase: DeleteBookCoverUseCase
    private let createBookUseCase: CreateBookUseCase
    private let deleteBookUseCase: DeleteBookUseCase
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private let bookOrder: Int
    private var bookTitle: String?
    private var bookColor: BookColor?
    private var bookCategory: String?
    
    init(
        fetchMemorialHouseNameUseCase: FetchMemorialHouseNameUseCase,
        createBookCoverUseCase: CreateBookCoverUseCase,
        deleteBookCoverUseCase: DeleteBookCoverUseCase,
        createBookUseCase: CreateBookUseCase,
        deleteBookUseCase: DeleteBookUseCase,
        bookOrder: Int
    ) {
        self.fetchMemorialHouseNameUseCase = fetchMemorialHouseNameUseCase
        self.createBookCoverUseCase = createBookCoverUseCase
        self.deleteBookCoverUseCase = deleteBookCoverUseCase
        self.createBookUseCase = createBookUseCase
        self.deleteBookUseCase = deleteBookUseCase
        self.bookOrder = bookOrder
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidAppear:
                self?.setBookColor(nowIndex: 0)
            case .changedBookTitle(let title):
                self?.output.send(.bookTitle(title: title))
            case .changedBookColor(let colorIndex):
                self?.setBookColor(nowIndex: colorIndex)
            case .changedBookCategory(let category):
                self?.output.send(.bookCategory(category: category))
            case .saveBookCover:
                Task { try await self?.saveBookCover() }
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func setBookColor(nowIndex: Int) {
        var previousIndex: Int?
        if let bookColor {
            previousIndex = bookColor.index
        }
        let bookColor = BookColor.indexToColor(index: nowIndex)
        self.bookColor = bookColor
        output.send(.bookColorIndex(previousIndex: previousIndex, nowIndex: nowIndex, bookColor: bookColor))
    }
    
    private func saveBookCover() async throws {
        guard let bookTitle, let bookColor else { return }
        let newBookCover = BookCover(
            order: bookOrder,
            title: bookTitle,
            imageURL: nil,
            color: bookColor,
            category: bookCategory
        )
        try await createBookCoverUseCase.execute(with: newBookCover)
        try await createBook(bookID: newBookCover.id)
        output.send(.moveToNext)
    }
    
    private func createBook(bookID: UUID) async throws {
        guard let bookTitle else { return }
        let newBook = Book(
            id: bookID,
            title: bookTitle,
            pages: [Page()]
        )
        try await createBookUseCase.execute(book: newBook)
    }
}
