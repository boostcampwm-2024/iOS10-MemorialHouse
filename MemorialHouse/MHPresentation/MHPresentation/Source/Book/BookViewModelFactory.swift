import MHFoundation
import MHDomain

public struct BookViewModelFactory {
    let fetchBookUseCase: FetchBookUseCase
    
    public init(fetchBookUseCase: FetchBookUseCase) {
        self.fetchBookUseCase = fetchBookUseCase
    }
    
    public func make(bookID: UUID) -> BookViewModel {
        BookViewModel(
            identifier: bookID,
            fetchBookUseCase: fetchBookUseCase
        )
    }
}
