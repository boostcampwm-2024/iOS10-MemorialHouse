import MHCore

public protocol BookCategoryRepository {
    func createBookCategory(name: String) async -> Result<Void, MHDataError>
    func fetchBookCategories() async -> Result<[String], MHDataError>
    func updateBookCategory(oldName: String, newName: String) async -> Result<Void, MHDataError>
    func deleteBookCategory(name: String) async -> Result<Void, MHDataError>
}
