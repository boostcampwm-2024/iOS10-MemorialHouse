import Combine
import MHCore
import MHDomain

public final class HomeViewModel: ViewModelType {
    enum Input {
        case viewDidLoad
        case selectedCategory(index: Int)
    }
    
    enum Output {
        case fetchedUserHouse
        case filteredBooks
    }
    
    private let output = PassthroughSubject<Output, Never>()
    private var fetchUserHouseUseCase: FetchUserHouseUseCase
    private var cancellables = Set<AnyCancellable>()
    private(set) var houseName = ""
    private(set) var categories = ["전체", "즐겨찾기"]
    private(set) var bookCovers = [BookCover]()
    private(set) var currentBookCovers = [BookCover]()
    
    public init(fetchUserHouseUseCase: FetchUserHouseUseCase) {
        self.fetchUserHouseUseCase = fetchUserHouseUseCase
    }
    
    @MainActor
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                self?.fetchUserHouse()
            case .selectedCategory(let index):
                self?.filterBooks(with: index)
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    @MainActor
    private func fetchUserHouse() {
        Task {
            let userHouse = await fetchUserHouseUseCase.execute()
            self.houseName = userHouse.name
            self.categories.append(contentsOf: userHouse.categories)
            self.bookCovers = userHouse.bookCovers
            self.currentBookCovers = userHouse.bookCovers
            output.send(.fetchedUserHouse)
            MHLogger.debug("\(#function): \(userHouse)")
        }
    }
    
    private func filterBooks(with index: Int) {
        if index == 0 {
            currentBookCovers = bookCovers
        } else if index == 1 {
            currentBookCovers = bookCovers.filter { $0.favorite }
        } else {
            currentBookCovers = bookCovers.filter { $0.category == categories[index] }
        }
        
        output.send(.filteredBooks)
    }
}
