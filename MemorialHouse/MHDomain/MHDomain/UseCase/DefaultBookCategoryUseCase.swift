public struct DefaultCreateBookCategoryUseCase: CreateBookCategoryUseCase {
    let repository: BookCategoryRepository
    
    public init(repository: BookCategoryRepository) {
        self.repository = repository
    }
    
    public func execute(with category: BookCategory) async throws {
        try await repository.createBookCategory(with: category)
    }
}

public struct DefaultFetchBookCategoriesUseCase: FetchBookCategoriesUseCase {
    let repository: BookCategoryRepository
    
    public init(repository: BookCategoryRepository) {
        self.repository = repository
    }
    
    public func execute() async throws -> [BookCategory] {
        try await repository.fetchBookCategories()
    }
}

public struct DefaultUpdateBookCategoryUseCase: UpdateBookCategoryUseCase {
    let repository: BookCategoryRepository
    
    public init(repository: BookCategoryRepository) {
        self.repository = repository
    }
    
    public func execute(oldName: String, with category: BookCategory) async throws {
        try await repository.updateBookCategory(oldName: oldName, with: category)
    }
}

public struct DefaultDeleteBookCategoryUseCase: DeleteBookCategoryUseCase {
    let repository: BookCategoryRepository
    
    public init(repository: BookCategoryRepository) {
        self.repository = repository
    }
    
    public func execute(with categoryName: String) async throws {
        try await repository.deleteBookCategory(with: categoryName)
    }
}
