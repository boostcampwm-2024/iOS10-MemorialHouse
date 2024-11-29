import MHDomain

public struct HomeViewModelFactory {
    let fetchMemorialHouseUseCase: FetchMemorialHouseUseCase
    let fetchCategoryUseCase: FetchBookCategoriesUseCase
    
    public init(
        fetchMemorialHouseUseCase: FetchMemorialHouseUseCase,
        fetchCategoryUseCase: FetchBookCategoriesUseCase
    ) {
        self.fetchMemorialHouseUseCase = fetchMemorialHouseUseCase
        self.fetchCategoryUseCase = fetchCategoryUseCase
    }
    
    public func make() -> HomeViewModel {
        HomeViewModel(fetchMemorialHouseUseCase: fetchMemorialHouseUseCase)
    }
}
