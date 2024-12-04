import MHFoundation
import MHDomain

public struct ReadPageViewModelFactory {
    private let fetchMediaUseCase: FetchMediaUseCase
    
    public init(fetchMediaUseCase: FetchMediaUseCase) {
        self.fetchMediaUseCase = fetchMediaUseCase
    }
    
    public func make(bookID: UUID, page: Page) -> ReadPageViewModel {
        ReadPageViewModel(
            fetchMediaUseCase: fetchMediaUseCase,
            bookID: bookID,
            page: page
        )
    }
}
