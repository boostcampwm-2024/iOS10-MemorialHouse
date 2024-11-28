import Combine
import MHCore
import MHDomain

public final class HomeViewModel: ViewModelType {
    public enum Input {
        case viewDidLoad
        case selectedCategory(category: String)
    }
    
    public enum Output {
        case fetchedMemorialHouseAndCategory
        case filteredBooks
        case fetchedFailure(String)
    }
    
    private let output = PassthroughSubject<Output, Never>()
    private let fetchMemorialHouseUseCase: FetchMemorialHouseUseCase
    private var cancellables = Set<AnyCancellable>()
    private(set) var houseName = ""
    private(set) var bookCovers = [BookCover]()
    private(set) var currentBookCovers = [BookCover]()
    
    public init(fetchMemorialHouseUseCase: FetchMemorialHouseUseCase) {
        self.fetchMemorialHouseUseCase = fetchMemorialHouseUseCase
    }
    
    @MainActor
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                Task {
                    do {
                        try await self?.fetchMemorialHouse()
                        self?.output.send(.fetchedMemorialHouseAndCategory)
                    } catch {
                        self?.output.send(.fetchedFailure("데이터 로드 중 에러가 발생했습니다."))
                        MHLogger.error("에러 발생: \(error.localizedDescription)")
                    }
                }
            case .selectedCategory(let category):
                self?.filterBooks(by: category)
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
}
