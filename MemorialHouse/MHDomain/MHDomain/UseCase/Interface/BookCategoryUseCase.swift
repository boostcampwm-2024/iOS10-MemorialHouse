public protocol CreateBookCategoryUseCase {
    func execute(with category: BookCategory) async throws
}

public protocol FetchBookCategoriesUseCase {
    func execute() async throws -> [BookCategory]
}

public protocol UpdateBookCategoryUseCase {
    func execute(with category: BookCategory) async throws
}

public protocol DeleteBookCategoryUseCase {
    func execute(with categoryName: String) async throws
}
