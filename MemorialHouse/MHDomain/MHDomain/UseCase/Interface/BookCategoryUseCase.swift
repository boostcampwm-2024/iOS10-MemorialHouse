public protocol CreateBookCategoryUseCase {
    func execute(name: String) async throws
}

public protocol FetchBookCategoriesUseCase {
    func execute() async throws -> [String]
}

public protocol UpdateBookCategoryUseCase {
    func execute(oldName: String, newName: String) async throws
}

public protocol DeleteBookCategoryUseCase {
    func execute(name: String) async throws
}
