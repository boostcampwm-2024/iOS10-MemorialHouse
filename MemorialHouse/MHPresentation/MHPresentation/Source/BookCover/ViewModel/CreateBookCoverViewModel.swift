import MHFoundation
import MHDomain
import Combine
import Photos

// TODO: - 에러 처리 필요
final class CreateBookCoverViewModel: ViewModelType {
    enum Input {
        case setBookColor
        case changedBookTitle(title: String?)
        case changedBookColor(colorIndex: Int)
        case changedBookImage(bookImage: Data?)
        case changedBookCategory(category: String?)
        case saveBookCover
        case deleteBookCover
    }
    
    enum Output {
        case memorialHouseName(name: String)
        case bookTitle(title: String?)
        case bookColorIndex(previousIndex: Int?, nowIndex: Int, bookColor: BookColor)
        case bookImage(imageData: Data?)
        case bookCategory(category: String?)
        case moveToNext(bookID: UUID)
        case moveToHome
        case settingFailure
    }
    
    private let fetchMemorialHouseNameUseCase: FetchMemorialHouseNameUseCase
    private let createBookCoverUseCase: CreateBookCoverUseCase
    private let deleteBookCoverUseCase: DeleteBookCoverUseCase
    private let createBookUseCase: CreateBookUseCase
    private let deleteBookUseCase: DeleteBookUseCase
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private var bookID: UUID?
    private let bookOrder: Int
    private var bookTitle: String?
    private var bookColor: BookColor?
    private var bookImageData: Data?
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
            case .setBookColor:
                self?.setBookColor(nowIndex: 0)
                Task { try await self?.fetchMemorialHouseName() }
            case .changedBookTitle(let title):
                self?.setBookTitle(title: title)
            case .changedBookColor(let colorIndex):
                self?.setBookColor(nowIndex: colorIndex)
            case .changedBookImage(let bookImage):
                self?.setBookImageData(imageData: bookImage)
            case .changedBookCategory(let category):
                self?.setBookCategory(category: category)
            case .saveBookCover:
                Task { try await self?.saveBookCover() }
            case .deleteBookCover:
                Task {
                    try await self?.deleteBookCover()
                    self?.output.send(.moveToHome)
                }
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func setBookTitle(title: String?) {
        bookTitle = title
        output.send(.bookTitle(title: title))
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
    
    private func setBookImageData(imageData: Data?) {
        bookImageData = imageData
        output.send(.bookImage(imageData: imageData))
    }
    
    private func setBookCategory(category: String?) {
        bookCategory = category
        output.send(.bookCategory(category: category))
    }
    
    private func fetchMemorialHouseName() async throws {
        let memorialHouseName = try await fetchMemorialHouseNameUseCase.execute()
        self.output.send(.memorialHouseName(name: memorialHouseName))
    }
    
    private func saveBookCover() async throws {
        guard let bookTitle, !bookTitle.isEmpty, let bookColor else {
            output.send(.settingFailure)
            return
        }
        let newBookCover = BookCover(
            order: bookOrder,
            title: bookTitle,
            imageData: bookImageData,
            color: bookColor,
            category: bookCategory
        )
        try await createBookCoverUseCase.execute(with: newBookCover)
        try await createBook(bookID: newBookCover.id)
        bookID = newBookCover.id
        output.send(.moveToNext(bookID: newBookCover.id))
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
    
    private func deleteBookCover() async throws {
        guard let bookID else { return }
        try await deleteBookUseCase.execute(id: bookID)
        try await deleteBookCoverUseCase.execute(id: bookID)
    }
}
