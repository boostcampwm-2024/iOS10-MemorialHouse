public protocol CreateBookCategoryUseCase: Sendable {
    func execute(with category: BookCategory) throws
}

public protocol FetchBookCategoriesUseCase: Sendable {
    func execute() throws -> [BookCategory]
}

public protocol UpdateBookCategoryUseCase: Sendable {
    func execute(oldName: String, with category: BookCategory) throws
}

public protocol DeleteBookCategoryUseCase: Sendable {
    func execute(with categoryName: String) throws
}
