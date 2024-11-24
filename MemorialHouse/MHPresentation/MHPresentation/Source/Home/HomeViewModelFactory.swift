import MHDomain

public struct HomeViewModelFactory {
    let fetchMemorialHouseUseCase: FetchMemorialHouseUseCase
    
    public init(fetchMemorialHouseUseCase: FetchMemorialHouseUseCase) {
        self.fetchMemorialHouseUseCase = fetchMemorialHouseUseCase
    }
    
    public func make() -> HomeViewModel {
        HomeViewModel(fetchMemorialHouseUseCase: fetchMemorialHouseUseCase)
    }
}
