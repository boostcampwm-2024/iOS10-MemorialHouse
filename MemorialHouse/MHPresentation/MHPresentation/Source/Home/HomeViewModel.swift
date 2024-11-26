import Combine
import MHCore
import MHDomain

public final class HomeViewModel: ViewModelType {
    public enum Input {
        case viewDidLoad
        case selectedCategory(index: Int)
    }
    
    public enum Output {
        case fetchedMemorialHouseAndCategory
        case filteredBooks
        case fetchedFailure(String)
    }
    
    private let output = PassthroughSubject<Output, Never>()
    private let fetchMemorialHouseUseCase: FetchMemorialHouseUseCase
    private let fetchCategoryUseCase: FetchCategoriesUseCase
    private var cancellables = Set<AnyCancellable>()
    private(set) var houseName = ""
    private(set) var categories = ["전체", "즐겨찾기"]
    private(set) var bookCovers = [BookCover]()
    private(set) var currentBookCovers = [BookCover]()
    
    public init(
        fetchMemorialHouseUseCase: FetchMemorialHouseUseCase,
        fetchCategoryUseCase: FetchCategoriesUseCase
    ) {
        self.fetchMemorialHouseUseCase = fetchMemorialHouseUseCase
        self.fetchCategoryUseCase = fetchCategoryUseCase
    }
    
    @MainActor
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                Task {
                    do {
                        try await self?.fetchMemorialHouse()
                        try await self?.fetchCategory()
                        self?.output.send(.fetchedMemorialHouseAndCategory)
                    } catch {
                        self?.output.send(.fetchedFailure("데이터 로드 중 에러가 발생했습니다."))
                        MHLogger.error("에러 발생: \(error.localizedDescription)")
                    }
                }
            case .selectedCategory(let index):
                self?.filterBooks(with: index)
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
    
    private func fetchCategory() async throws {
        let categories = try await fetchCategoryUseCase.execute()
        self.categories += categories
    }
    
    private func filterBooks(with index: Int) {
        guard index >= 0 && index < categories.count else {
            MHLogger.error("유효하지 않은 인덱스: \(index)")
            return
        }

        switch categories[index] {
        case "전체":
            currentBookCovers = bookCovers
        case "즐겨찾기":
            currentBookCovers = bookCovers.filter { $0.favorite }
        default:
            currentBookCovers = bookCovers.filter { $0.category == categories[index] }
        }

        output.send(.filteredBooks)
    }
}
