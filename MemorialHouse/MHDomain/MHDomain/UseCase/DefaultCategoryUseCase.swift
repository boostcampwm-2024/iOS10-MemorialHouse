public struct DefaultCreateCategoryUseCase: CreateBookCategoryUseCase {
    let repository: BookCategoryRepository
    
    public init(repository: BookCategoryRepository) {
        self.repository = repository
    }
    
    public func execute(name: String) async throws {
        let result = await repository.createBookCategory(name: name)
        try result.get()
    }
}

public struct DefaultFetchCategoriesUseCase: FetchBookCategoriesUseCase {
    let repository: BookCategoryRepository
    
    public init(repository: BookCategoryRepository) {
        self.repository = repository
    }
    
    public func execute() async throws -> [String] {
        let result = await repository.fetchBookCategories()
        return try result.get()
    }
}

public struct DefaultUpdateCategoryUseCase: UpdateBookCategoryUseCase {
    let repository: BookCategoryRepository
    
    public init(repository: BookCategoryRepository) {
        self.repository = repository
    }
    
    public func execute(oldName: String, newName: String) async throws {
        let result = await repository.updateBookCategory(oldName: oldName, newName: newName)
        try result.get()
    }
}

public struct DefaultDeleteCategoryUseCase: DeleteBookCategoryUseCase {
    let repository: BookCategoryRepository
    
    public init(repository: BookCategoryRepository) {
        self.repository = repository
    }
    
    public func execute(name: String) async throws {
        let result = await repository.deleteBookCategory(name: name)
        try result.get()
    }
}
