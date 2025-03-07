public protocol CreateBookCategoryUseCase: Sendable {
    func execute(with category: BookCategory) async throws
}

public protocol FetchBookCategoriesUseCase: Sendable {
    func execute() async throws -> [BookCategory]
}

public protocol UpdateBookCategoryUseCase: Sendable {
    func execute(oldName: String, with category: BookCategory) async throws
}

public protocol DeleteBookCategoryUseCase: Sendable {
    func execute(with categoryName: String) async throws
}
