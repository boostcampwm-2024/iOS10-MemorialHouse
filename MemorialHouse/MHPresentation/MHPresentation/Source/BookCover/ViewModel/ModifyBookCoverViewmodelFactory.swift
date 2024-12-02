import MHFoundation
import MHDomain

public struct ModifyBookCoverViewModelFactory {
    private let fetchMemorialHouseNameUseCase: FetchMemorialHouseNameUseCase
    private let fetchBookCoverUseCase: FetchBookCoverUseCase
    private let updateBookCoverUseCase: UpdateBookCoverUseCase
    
    public init(
        fetchMemorialHouseNameUseCase: FetchMemorialHouseNameUseCase,
        fetchBookCoverUseCase: FetchBookCoverUseCase,
        updateBookCoverUseCase: UpdateBookCoverUseCase
    ) {
        self.fetchMemorialHouseNameUseCase = fetchMemorialHouseNameUseCase
        self.fetchBookCoverUseCase = fetchBookCoverUseCase
        self.updateBookCoverUseCase = updateBookCoverUseCase
    }
    
    func make(bookID: UUID) -> ModifyBookCoverViewModel {
        return ModifyBookCoverViewModel(
            fetchMemorialHouseNameUseCase: fetchMemorialHouseNameUseCase,
            fetchBookCoverUseCase: fetchBookCoverUseCase,
            updateBookCoverUseCase: updateBookCoverUseCase,
            bookID: bookID
        )
    }
}
