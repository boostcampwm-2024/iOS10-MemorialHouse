import MHDomain

public struct HomeViewModelFactory {
    let fetchMemorialHouseUseCase: FetchMemorialHouseUseCase
    let updateBookCoverUseCase: UpdateBookCoverUseCase
    
    public init(
        fetchMemorialHouseUseCase: FetchMemorialHouseUseCase,
        updateBookCoverUseCase: UpdateBookCoverUseCase
    ) {
        self.fetchMemorialHouseUseCase = fetchMemorialHouseUseCase
        self.updateBookCoverUseCase = updateBookCoverUseCase
    }
    
    public func make() -> HomeViewModel {
        HomeViewModel(
            fetchMemorialHouseUseCase: fetchMemorialHouseUseCase,
            updateBookCoverUseCase: updateBookCoverUseCase
        )
    }
}
