import Combine
import MHCore
import MHDomain

public final class HomeViewModel: ViewModelType {
    enum Input {
        case viewDidLoad
    }
    
    enum Output {
        case fetchedUserHouse
    }
    
    private let output = PassthroughSubject<Output, Never>()
    private var fetchUserHouseUseCase: FetchUserHouseUseCase
    private var cancellables = Set<AnyCancellable>()
    private(set) var houseName = ""
    private(set) var categories = ["전체", "즐겨찾기"]
    private(set) var bookCovers = [BookCover]()
    
    public init(fetchUserHouseUseCase: FetchUserHouseUseCase) {
        self.fetchUserHouseUseCase = fetchUserHouseUseCase
    }
    
    @MainActor
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                self?.fetchUserHouse()
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
            output.send(.fetchedUserHouse)
            MHLogger.debug("\(#function): \(userHouse)")
        }
    }
}
