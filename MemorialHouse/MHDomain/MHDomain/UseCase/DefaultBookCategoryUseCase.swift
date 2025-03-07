public struct DefaultCreateBookCategoryUseCase: CreateBookCategoryUseCase {
    let repository: BookCategoryRepository
    
    public init(repository: BookCategoryRepository) {
        self.repository = repository
    }
    
    public func execute(with category: BookCategory) throws {
        try repository.createBookCategory(with: category)
    }
}

public struct DefaultFetchBookCategoriesUseCase: FetchBookCategoriesUseCase {
    let repository: BookCategoryRepository
    
    public init(repository: BookCategoryRepository) {
        self.repository = repository
    }
    
    public func execute() throws -> [BookCategory] {
        try repository.fetchBookCategories()
    }
}

public struct DefaultUpdateBookCategoryUseCase: UpdateBookCategoryUseCase {
    let repository: BookCategoryRepository
    
    public init(repository: BookCategoryRepository) {
        self.repository = repository
    }
    
    public func execute(oldName: String, with category: BookCategory) throws {
        try repository.updateBookCategory(oldName: oldName, with: category)
    }
}

public struct DefaultDeleteBookCategoryUseCase: DeleteBookCategoryUseCase {
    let repository: BookCategoryRepository
    
    public init(repository: BookCategoryRepository) {
        self.repository = repository
    }
    
    public func execute(with categoryName: String) throws {
        try repository.deleteBookCategory(with: categoryName)
    }
}
