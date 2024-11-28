import MHFoundation
import MHDomain

public struct ReadPageViewModelFactory {
    public init() { }
    
    public func make(page: Page) -> ReadPageViewModel {
        ReadPageViewModel(page: page)
    }
}
