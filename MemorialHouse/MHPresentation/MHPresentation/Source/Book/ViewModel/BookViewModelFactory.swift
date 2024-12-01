import MHFoundation
import MHDomain

public struct BookViewModelFactory {
    private let fetchBookUseCase: FetchBookUseCase
    
    public init(fetchBookUseCase: FetchBookUseCase) {
        self.fetchBookUseCase = fetchBookUseCase
    }
    
    public func make(bookID: UUID) -> BookViewModel {
        BookViewModel(
            fetchBookUseCase: fetchBookUseCase,
            identifier: bookID
        )
    }
}
