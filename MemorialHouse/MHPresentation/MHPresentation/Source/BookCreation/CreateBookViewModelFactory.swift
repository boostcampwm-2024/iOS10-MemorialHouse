import MHDomain

public struct CreateBookViewModelFactory {
    private let createBookCoverUseCase: CreateBookCoverUseCase
    
    public init(
        createBookCoverUseCase: CreateBookCoverUseCase
    ) {
        self.createBookCoverUseCase = createBookCoverUseCase
    }
    
    func make(houseName: String) -> CreateBookViewModel {
        CreateBookViewModel(
            createBookCoverUseCase: createBookCoverUseCase,
            houseName: houseName
        )
    }
}
