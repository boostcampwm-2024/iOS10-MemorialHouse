import MHCore
import MHDomain

public struct LocalBookCategoryRepository: BookCategoryRepository {
    private let storage: BookCategoryStorage
    
    public init(storage: BookCategoryStorage) {
        self.storage = storage
    }
    
    public func createBookCategory(with category: BookCategory) async throws {
        try await storage.create(with: BookCategoryDTO(order: category.order, name: category.name))
    }
    
    public func fetchBookCategories() async throws -> [BookCategory] {
        let bookCategoryEntities = try await storage.fetch()
        return bookCategoryEntities.compactMap { $0.convertToBookCategory() }
    }
    
    public func updateBookCategory(oldName: String, with category: BookCategory) async throws {
        try await storage.update(
            oldName: oldName,
            with: BookCategoryDTO(order: category.order, name: category.name)
        )
    }
    
    public func deleteBookCategory(with categoryName: String) async throws {
        try await storage.delete(with: categoryName)
    }
}
