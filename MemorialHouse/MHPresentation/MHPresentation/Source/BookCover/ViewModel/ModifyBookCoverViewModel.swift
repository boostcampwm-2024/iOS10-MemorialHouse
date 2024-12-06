import MHFoundation
import MHDomain
import Combine

// TODO: - 에러 처리 필요
final class ModifyBookCoverViewModel: ViewModelType {
    enum Input {
        case loadBookCover
        case changedBookTitle(title: String?)
        case changedBookColor(colorIndex: Int)
        case changedBookImage(bookImage: Data?)
        case changedBookCategory(category: String?)
        case saveBookCover
        case cancelModifyBookCover
    }
    
    enum Output {
        case memorialHouseName(name: String)
        case setModifyView(title: String?, category: String?)
        case bookTitle(title: String?)
        case bookColorIndex(previousIndex: Int?, nowIndex: Int, bookColor: BookColor)
        case bookImage(imageData: Data?)
        case bookCategory(category: String?)
        case moveToHome
        case settingFailure
    }
    
    private let fetchMemorialHouseNameUseCase: FetchMemorialHouseNameUseCase
    private let fetchBookCoverUseCase: FetchBookCoverUseCase
    private let updateBookCoverUseCase: UpdateBookCoverUseCase
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private let bookID: UUID
    private var bookOrder: Int?
    private var bookTitle: String?
    private var bookColor: BookColor?
    private var bookImageData: Data?
    private var bookCategory: String?
    
    init(
        fetchMemorialHouseNameUseCase: FetchMemorialHouseNameUseCase,
        fetchBookCoverUseCase: FetchBookCoverUseCase,
        updateBookCoverUseCase: UpdateBookCoverUseCase,
        bookID: UUID
    ) {
        self.fetchMemorialHouseNameUseCase = fetchMemorialHouseNameUseCase
        self.fetchBookCoverUseCase = fetchBookCoverUseCase
        self.updateBookCoverUseCase = updateBookCoverUseCase
        self.bookID = bookID
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .loadBookCover:
                Task {
                    try await self?.fetchMemorialHouseName()
                    try await self?.fetchBookCover()
                }
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
            case .cancelModifyBookCover:
                self?.output.send(.moveToHome)
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
    
    private func fetchBookCover() async throws {
        guard let bookCover = try await fetchBookCoverUseCase.execute(id: bookID) else { return }
        bookOrder = bookCover.order
        bookTitle = bookCover.title
        bookColor = bookCover.color
        bookImageData = bookCover.imageData
        bookCategory = bookCover.category
        output.send(.bookTitle(title: bookTitle))
        output.send(.bookImage(imageData: bookImageData))
        output.send(.bookCategory(category: bookCategory))
        if let bookColor {
            output.send(.bookColorIndex(previousIndex: nil, nowIndex: bookColor.index, bookColor: bookColor))
        }
        output.send(.setModifyView(title: bookTitle, category: bookCategory))
    }
    
    private func saveBookCover() async throws {
        guard let bookTitle, !bookTitle.isEmpty, let bookOrder, let bookColor else {
            output.send(.settingFailure)
            return
        }
        let newBookCover = BookCover(
            id: bookID,
            order: bookOrder,
            title: bookTitle,
            imageData: bookImageData,
            color: bookColor,
            category: bookCategory
        )
        try await updateBookCoverUseCase.execute(id: bookID, with: newBookCover)
        output.send(.moveToHome)
    }
}
