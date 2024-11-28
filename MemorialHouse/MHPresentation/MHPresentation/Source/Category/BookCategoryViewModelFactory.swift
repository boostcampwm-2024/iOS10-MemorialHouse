import MHDomain

public struct BookCategoryViewModelFactory {
    let createBookCategoryUseCase: CreateBookCategoryUseCase
    let updateBookCategoryUseCase: UpdateBookCategoryUseCase
    let deleteBookCategoryUseCase: DeleteBookCategoryUseCase
    
    public init(
        createBookCategoryUseCase: CreateBookCategoryUseCase,
        updateBookCategoryUseCase: UpdateBookCategoryUseCase,
        deleteBookCategoryUseCase: DeleteBookCategoryUseCase
    ) {
        self.createBookCategoryUseCase = createBookCategoryUseCase
        self.updateBookCategoryUseCase = updateBookCategoryUseCase
        self.deleteBookCategoryUseCase = deleteBookCategoryUseCase
    }
    
    func make() -> BookCategoryViewModel {
        BookCategoryViewModel(
            createBookCategoryUseCase: createBookCategoryUseCase,
            updateBookCategoryUseCase: updateBookCategoryUseCase,
            deleteBookCategoryUseCase: deleteBookCategoryUseCase
        )
    }
}
