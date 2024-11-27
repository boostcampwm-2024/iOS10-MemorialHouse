public protocol CreateCategoryUseCase {
    func execute(name: String) async throws
}

public protocol FetchCategoriesUseCase {
    func execute() async throws -> [String]
}

public protocol UpdateCategoryUseCase {
    func execute(oldName: String, newName: String) async throws
}

public protocol DeleteCategoryUseCase {
    func execute(name: String) async throws
}
