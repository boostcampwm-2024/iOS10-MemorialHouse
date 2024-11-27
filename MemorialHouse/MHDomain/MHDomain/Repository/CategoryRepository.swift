public protocol CategoryRepository: Sendable {
    func createCategory(name: String) async -> Result<Void, Error>
    func fetchCategories() async -> Result<[String], Error>
    func updateCategory(oldName: String, newName: String) async -> Result<Void, Error>
    func deleteCategory(name: String) async -> Result<Void, Error>
}
