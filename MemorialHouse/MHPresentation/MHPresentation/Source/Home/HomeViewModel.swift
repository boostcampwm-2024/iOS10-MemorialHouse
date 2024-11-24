import Combine
import MHCore
import MHDomain

public final class HomeViewModel: ViewModelType {
    enum Input {
        case viewDidLoad
    }
    
    enum Output {
        case fetchedUserHouse(UserHouse)
    }
    
    private let output = PassthroughSubject<Output, Never>()
    private var fetchUserHouseUseCase: FetchUserHouseUseCase
    private var cancellables = Set<AnyCancellable>()
    private(set) var userHouse = PassthroughSubject<UserHouse, Never>()
    
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
    
    }
}
