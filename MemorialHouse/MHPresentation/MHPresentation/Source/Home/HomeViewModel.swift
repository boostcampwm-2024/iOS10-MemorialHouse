import Combine
import MHCore
import MHDomain
import MHFoundation

public final class HomeViewModel: ViewModelType {
    public enum Input {
        case viewDidLoad
        case selectedCategory(category: String)
        case dragAndDropBookCover(currentIndex: Int, destinationIndex: Int)
        case likeButtonTapped(bookId: UUID)
    }
    
    public enum Output {
        case fetchedMemorialHouseAndCategory
        case filteredBooks
        case fetchedFailure(String)
        case dragAndDropFinished
        case likeButtonTapped
    }
    
    private let output = PassthroughSubject<Output, Never>()
    private let fetchMemorialHouseUseCase: FetchMemorialHouseUseCase
    private let updateBookCoverUseCase: UpdateBookCoverUseCase
    private var cancellables = Set<AnyCancellable>()
    private(set) var houseName = ""
    private(set) var bookCovers = [BookCover]()
    private(set) var currentBookCovers = [BookCover]()
    
    public init(
        fetchMemorialHouseUseCase: FetchMemorialHouseUseCase,
        updateBookCoverUseCase: UpdateBookCoverUseCase
    ) {
        self.fetchMemorialHouseUseCase = fetchMemorialHouseUseCase
        self.updateBookCoverUseCase = updateBookCoverUseCase
    }
    
    @MainActor
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            Task {
                switch event {
                case .viewDidLoad:
                    do {
                        try await self?.fetchMemorialHouse()
                        self?.output.send(.fetchedMemorialHouseAndCategory)
                    } catch {
                        self?.output.send(.fetchedFailure("데이터 로드 중 에러가 발생했습니다."))
                        MHLogger.error("데이터 로드 에러 발생: \(error.localizedDescription)")
                    }
                case .selectedCategory(let category):
                    self?.filterBooks(by: category)
                case .dragAndDropBookCover(let currentIndex, let destinationIndex):
                    self?.dragAndDropBookCover(from: currentIndex, to: destinationIndex)
                case .likeButtonTapped(let bookId):
                    do {
                        try await self?.likeButtonTapped(bookId: bookId)
                    } catch {
                        self?.output.send(.fetchedFailure("좋아요에 실패했습니다."))
                        MHLogger.error("좋아요 에러 발생: \(error.localizedDescription)")
                    }
                }
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func fetchMemorialHouse() async throws {
        let memorialHouse = try await fetchMemorialHouseUseCase.execute()
        self.houseName = memorialHouse.name
        self.bookCovers = memorialHouse.bookCovers
        self.currentBookCovers = memorialHouse.bookCovers
    }
    
    private func filterBooks(by category: String) {
        switch category {
        case "전체":
            currentBookCovers = bookCovers
        case "즐겨찾기":
            currentBookCovers = bookCovers.filter { $0.favorite }
        default:
            currentBookCovers = bookCovers.filter { $0.category == category }
        }
        
        output.send(.filteredBooks)
    }
    
    private func dragAndDropBookCover(from currentIndex: Int, to destinationIndex: Int) {
        let currentBookCover = currentBookCovers[currentIndex]
        let targetBookCover = currentBookCovers[destinationIndex]
        bookCovers.remove(at: currentBookCover.order)
        bookCovers.insert(currentBookCover, at: targetBookCover.order)
        currentBookCovers.remove(at: currentIndex)
        currentBookCovers.insert(currentBookCover, at: destinationIndex)
        output.send(.dragAndDropFinished)
    }
    
    private func likeButtonTapped(bookId: UUID) async throws {
        guard let index = currentBookCovers.firstIndex(where: { $0.id == bookId }) else { return }
        let currentBookCover = currentBookCovers[index]
        let bookCover = BookCover(
            id: currentBookCover.id,
            order: currentBookCover.order,
            title: currentBookCover.title,
            imageURL: currentBookCover.category,
            color: currentBookCover.color,
            category: currentBookCover.imageURL,
            favorite: !currentBookCover.favorite
        )
        try await updateBookCoverUseCase.execute(id: bookId, with: bookCover)
        currentBookCovers[index] = bookCover
        output.send(.likeButtonTapped)
    }
}
