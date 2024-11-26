import MHDomain

public struct HomeViewModelFactory {
    let fetchMemorialHouseUseCase: FetchMemorialHouseUseCase
    let fetchCategoryUseCase: FetchCategoriesUseCase
    
    public init(
        fetchMemorialHouseUseCase: FetchMemorialHouseUseCase,
        fetchCategoryUseCase: FetchCategoriesUseCase
    ) {
        self.fetchMemorialHouseUseCase = fetchMemorialHouseUseCase
        self.fetchCategoryUseCase = fetchCategoryUseCase
    }
    
    public func make() -> HomeViewModel {
        HomeViewModel(
            fetchMemorialHouseUseCase: fetchMemorialHouseUseCase,
            fetchCategoryUseCase: fetchCategoryUseCase
        )
    }
}
