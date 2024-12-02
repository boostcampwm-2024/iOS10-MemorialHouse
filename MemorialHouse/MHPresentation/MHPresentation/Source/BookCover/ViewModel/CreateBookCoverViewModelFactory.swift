import MHFoundation
import MHDomain

public struct CreateBookCoverViewModelFactory {
    private let fetchMemorialHouseNameUseCase: FetchMemorialHouseNameUseCase
    private let createBookCoverUseCase: CreateBookCoverUseCase
    private let deleteBookCoverUseCase: DeleteBookCoverUseCase
    private let createBookUseCase: CreateBookUseCase
    private let deleteBookUseCase: DeleteBookUseCase
    
    public init(
        fetchMemorialHouseNameUseCase: FetchMemorialHouseNameUseCase,
        createBookCoverUseCase: CreateBookCoverUseCase,
        deleteBookCoverUseCase: DeleteBookCoverUseCase,
        createBookUseCase: CreateBookUseCase,
        deleteBookUseCase: DeleteBookUseCase
    ) {
        self.fetchMemorialHouseNameUseCase = fetchMemorialHouseNameUseCase
        self.createBookCoverUseCase = createBookCoverUseCase
        self.deleteBookCoverUseCase = deleteBookCoverUseCase
        self.createBookUseCase = createBookUseCase
        self.deleteBookUseCase = deleteBookUseCase
    }
    
    func make(bookCount order: Int) -> CreateBookCoverViewModel {
        return CreateBookCoverViewModel(
            fetchMemorialHouseNameUseCase: fetchMemorialHouseNameUseCase,
            createBookCoverUseCase: createBookCoverUseCase,
            deleteBookCoverUseCase: deleteBookCoverUseCase,
            createBookUseCase: createBookUseCase,
            deleteBookUseCase: deleteBookUseCase,
            bookOrder: order
        )
    }
}
