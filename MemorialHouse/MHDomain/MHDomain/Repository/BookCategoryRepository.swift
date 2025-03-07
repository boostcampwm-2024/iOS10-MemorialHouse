import MHCore

public protocol BookCategoryRepository: Sendable {
    func createBookCategory(with category: BookCategory) async throws
    func fetchBookCategories() async throws -> [BookCategory]
    func updateBookCategory(oldName: String, with category: BookCategory) async throws
    func deleteBookCategory(with categoryName: String) async throws
}
