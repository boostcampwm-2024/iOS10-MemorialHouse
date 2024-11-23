import MHDomain

public struct HomeViewModelFactory {
    let fetchUserHouseUseCase: FetchUserHouseUseCase
    
    public init(fetchUserHouseUseCase: FetchUserHouseUseCase) {
        self.fetchUserHouseUseCase = fetchUserHouseUseCase
    }
    
    public func make() -> HomeViewModel {
        HomeViewModel(fetchUserHouseUseCase: fetchUserHouseUseCase)
    }
}
