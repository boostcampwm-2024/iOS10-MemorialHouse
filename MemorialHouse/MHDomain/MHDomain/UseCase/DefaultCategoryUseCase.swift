public struct DefaultCreateBookCategoryUseCase: CreateBookCategoryUseCase {
    let repository: BookCategoryRepository
    
    public init(repository: BookCategoryRepository) {
        self.repository = repository
    }
    
    public func execute(with category: BookCategory) async throws {
        let result = await repository.createBookCategory(with: category)
        try result.get()
    }
}

public struct DefaultFetchBookCategoriesUseCase: FetchBookCategoriesUseCase {
    let repository: BookCategoryRepository
    
    public init(repository: BookCategoryRepository) {
        self.repository = repository
    }
    
    public func execute() async throws -> [BookCategory] {
        let result = await repository.fetchBookCategories()
        return try result.get()
    }
}

public struct DefaultUpdateBookCategoryUseCase: UpdateBookCategoryUseCase {
    let repository: BookCategoryRepository
    
    public init(repository: BookCategoryRepository) {
        self.repository = repository
    }
    
    public func execute(with category: BookCategory) async throws {
        let result = await repository.updateBookCategory(with: category)
        try result.get()
    }
}

public struct DefaultDeleteBookCategoryUseCase: DeleteBookCategoryUseCase {
    let repository: BookCategoryRepository
    
    public init(repository: BookCategoryRepository) {
        self.repository = repository
    }
    
    public func execute(with categoryName: String) async throws {
        let result = await repository.deleteBookCategory(with: categoryName)
        try result.get()
    }
}
