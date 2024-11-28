import MHCore

public protocol BookCategoryRepository: Sendable {
    func createBookCategory(with category: BookCategory) async -> Result<Void, MHDataError>
    func fetchBookCategories() async -> Result<[BookCategory], MHDataError>
    func updateBookCategory(with category: BookCategory) async -> Result<Void, MHDataError>
    func deleteBookCategory(with categoryName: String) async -> Result<Void, MHDataError>
}
