import MHCore
import MHDomain

public struct LocalBookCategoryRepository: BookCategoryRepository {
    private let storage: BookCategoryStorage
    
    public init(storage: BookCategoryStorage) {
        self.storage = storage
    }
    
    public func createBookCategory(with category: BookCategory) throws {
        try storage.create(with: BookCategoryDTO(order: category.order, name: category.name))
    }
    
    public func fetchBookCategories() throws -> [BookCategory] {
        let bookCategoryEntities = try storage.fetch()
        return bookCategoryEntities.compactMap { $0.convertToBookCategory() }
    }
    
    public func updateBookCategory(oldName: String, with category: BookCategory) throws {
        try storage.update(
            oldName: oldName,
            with: BookCategoryDTO(order: category.order, name: category.name)
        )
    }
    
    public func deleteBookCategory(with categoryName: String) throws {
        try storage.delete(with: categoryName)
    }
}
