import MHCore

public protocol BookCategoryRepository: Sendable {
    func createBookCategory(with category: BookCategory) throws
    func fetchBookCategories() throws -> [BookCategory]
    func updateBookCategory(oldName: String, with category: BookCategory) throws
    func deleteBookCategory(with categoryName: String) throws
}
