import MHDomain

public struct BookViewModelFactory {
    let fetchBookUseCase: FetchBookUseCase
    
    public init(fetchBookUseCase: FetchBookUseCase) {
        self.fetchBookUseCase = fetchBookUseCase
    }
    
    public func make() -> BookViewModel {
        BookViewModel(fetchBookUseCase: fetchBookUseCase)
    }
}
