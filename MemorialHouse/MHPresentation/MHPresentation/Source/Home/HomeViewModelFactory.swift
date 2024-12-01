import MHDomain

public struct HomeViewModelFactory {
    let fetchMemorialHouseNameUseCase: FetchMemorialHouseNameUseCase
    let fetchAllBookCoverUseCase: FetchAllBookCoverUseCase
    let updateBookCoverUseCase: UpdateBookCoverUseCase
    
    public init(
        fetchMemorialHouseNameUseCase: FetchMemorialHouseNameUseCase,
        fetchAllBookCoverUseCase: FetchAllBookCoverUseCase,
        updateBookCoverUseCase: UpdateBookCoverUseCase
    ) {
        self.fetchMemorialHouseNameUseCase = fetchMemorialHouseNameUseCase
        self.fetchAllBookCoverUseCase = fetchAllBookCoverUseCase
        self.updateBookCoverUseCase = updateBookCoverUseCase
    }
    
    public func make() -> HomeViewModel {
        HomeViewModel(
            fetchMemorialHouseUseCase: fetchMemorialHouseNameUseCase,
            fetchAllBookCoverUseCase: fetchAllBookCoverUseCase,
            updateBookCoverUseCase: updateBookCoverUseCase
        )
    }
}
