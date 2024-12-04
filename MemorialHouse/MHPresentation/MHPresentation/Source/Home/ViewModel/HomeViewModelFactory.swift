import MHDomain

public struct HomeViewModelFactory {
    let fetchMemorialHouseNameUseCase: FetchMemorialHouseNameUseCase
    let fetchAllBookCoverUseCase: FetchAllBookCoverUseCase
    let updateBookCoverUseCase: UpdateBookCoverUseCase
    let deleteBookCoverUseCase: DeleteBookCoverUseCase
    
    public init(
        fetchMemorialHouseNameUseCase: FetchMemorialHouseNameUseCase,
        fetchAllBookCoverUseCase: FetchAllBookCoverUseCase,
        updateBookCoverUseCase: UpdateBookCoverUseCase,
        deleteBookCoverUseCase: DeleteBookCoverUseCase
    ) {
        self.fetchMemorialHouseNameUseCase = fetchMemorialHouseNameUseCase
        self.fetchAllBookCoverUseCase = fetchAllBookCoverUseCase
        self.updateBookCoverUseCase = updateBookCoverUseCase
        self.deleteBookCoverUseCase = deleteBookCoverUseCase
    }
    
    public func make() -> HomeViewModel {
        HomeViewModel(
            fetchMemorialHouseUseCase: fetchMemorialHouseNameUseCase,
            fetchAllBookCoverUseCase: fetchAllBookCoverUseCase,
            updateBookCoverUseCase: updateBookCoverUseCase,
            deleteBookCoverUseCase: deleteBookCoverUseCase
        )
    }
}
