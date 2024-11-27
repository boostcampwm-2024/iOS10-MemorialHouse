public struct DefaultCreateCategoryUseCase: CreateCategoryUseCase {
    let repository: CategoryRepository
    
    public init(repository: CategoryRepository) {
        self.repository = repository
    }
    
    public func execute(name: String) async throws {
        let result = await repository.createCategory(name: name)
        try result.get()
    }
}

public struct DefaultFetchCategoriesUseCase: FetchCategoriesUseCase {
    let repository: CategoryRepository
    
    public init(repository: CategoryRepository) {
        self.repository = repository
    }
    
    public func execute() async throws -> [String] {
        let result = await repository.fetchCategories()
        return try result.get()
    }
}

public struct DefaultUpdateCategoryUseCase: UpdateCategoryUseCase {
    let repository: CategoryRepository
    
    public init(repository: CategoryRepository) {
        self.repository = repository
    }
    
    public func execute(oldName: String, newName: String) async throws {
        let result = await repository.updateCategory(oldName: oldName, newName: newName)
        try result.get()
    }
}

public struct DefaultDeleteCategoryUseCase: DeleteCategoryUseCase {
    let repository: CategoryRepository
    
    public init(repository: CategoryRepository) {
        self.repository = repository
    }
    
    public func execute(name: String) async throws {
        let result = await repository.deleteCategory(name: name)
        try result.get()
    }
}
