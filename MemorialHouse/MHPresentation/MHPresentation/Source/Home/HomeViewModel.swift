import Combine
import MHCore
import MHDomain

public final class HomeViewModel: ViewModelType {
    public enum Input {
        case viewDidLoad
        case selectedCategory(index: Int)
    }
    
    public enum Output {
        case fetchedMemorialHouse
        case filteredBooks
    }
    
    private let output = PassthroughSubject<Output, Never>()
    private var fetchMemorialHouseUseCase: FetchMemorialHouseUseCase
    private var cancellables = Set<AnyCancellable>()
    private(set) var houseName = ""
    private(set) var categories = ["전체", "즐겨찾기"]
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
                self?.fetchMemorialHouse()
            case .selectedCategory(let index):
                self?.filterBooks(with: index)
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    @MainActor
    private func fetchMemorialHouse() {
        Task { @MainActor in
            let memorialHouse = await fetchMemorialHouseUseCase.execute()
            self.houseName = memorialHouse.name
            self.categories.append(contentsOf: memorialHouse.categories)
            self.bookCovers = memorialHouse.bookCovers
            self.currentBookCovers = memorialHouse.bookCovers
            
            output.send(.fetchedMemorialHouse)
        }
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
