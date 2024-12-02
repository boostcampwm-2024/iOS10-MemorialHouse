import MHFoundation
import MHDomain

public struct ModifyBookCoverViewModelFactory {
    private let fetchBookCoverUseCase: FetchBookCoverUseCase
    private let updateBookCoverUseCase: UpdateBookCoverUseCase
    
    init(
        fetchBookCoverUseCase: FetchBookCoverUseCase,
        updateBookCoverUseCase: UpdateBookCoverUseCase
    ) {
        self.fetchBookCoverUseCase = fetchBookCoverUseCase
        self.updateBookCoverUseCase = updateBookCoverUseCase
    }
    
    func make(bookID: UUID) -> ModifyBookCoverViewModel {
        return ModifyBookCoverViewModel(
            fetchBookCoverUseCase: fetchBookCoverUseCase,
            updateBookCoverUseCase: updateBookCoverUseCase,
            bookID: bookID
        )
    }
}
