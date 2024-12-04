import MHDomain

public struct BookCategoryViewModelFactory {
    let createBookCategoryUseCase: CreateBookCategoryUseCase
    let fetchBookCategoriesUseCase: FetchBookCategoriesUseCase
    let updateBookCategoryUseCase: UpdateBookCategoryUseCase
    let deleteBookCategoryUseCase: DeleteBookCategoryUseCase
    
    public init(
        createBookCategoryUseCase: CreateBookCategoryUseCase,
        fetchBookCategoriesUseCase: FetchBookCategoriesUseCase,
        updateBookCategoryUseCase: UpdateBookCategoryUseCase,
        deleteBookCategoryUseCase: DeleteBookCategoryUseCase
    ) {
        self.createBookCategoryUseCase = createBookCategoryUseCase
        self.fetchBookCategoriesUseCase = fetchBookCategoriesUseCase
        self.updateBookCategoryUseCase = updateBookCategoryUseCase
        self.deleteBookCategoryUseCase = deleteBookCategoryUseCase
    }
    
    func makeForHome() -> BookCategoryViewModel {
        BookCategoryViewModel(
            createBookCategoryUseCase: createBookCategoryUseCase,
            fetchBookCategoriesUseCase: fetchBookCategoriesUseCase,
            updateBookCategoryUseCase: updateBookCategoryUseCase,
            deleteBookCategoryUseCase: deleteBookCategoryUseCase
        )
    }
    
    func makeForCreateBook() -> BookCategoryViewModel {
        BookCategoryViewModel(
            createBookCategoryUseCase: createBookCategoryUseCase,
            fetchBookCategoriesUseCase: fetchBookCategoriesUseCase,
            updateBookCategoryUseCase: updateBookCategoryUseCase,
            deleteBookCategoryUseCase: deleteBookCategoryUseCase,
            categories: []
        )
    }
}
