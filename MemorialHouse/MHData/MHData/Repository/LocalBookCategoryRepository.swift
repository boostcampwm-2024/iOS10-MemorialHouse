import MHCore
import MHDomain

public struct LocalBookCategoryRepository: BookCategoryRepository {
    private let storage: BookCategoryStorage
    
    public init(storage: BookCategoryStorage) {
        self.storage = storage
    }
    
    public func createBookCategory(with category: BookCategory) async -> Result<Void, MHDataError> {
        return await storage.create(with: BookCategoryDTO(order: category.order, name: category.name))
    }
    
    public func fetchBookCategories() async -> Result<[BookCategory], MHDataError> {
        let result = await storage.fetch()
        
        switch result {
        case .success(let bookCategoryDTOs):
            return .success(bookCategoryDTOs.compactMap { $0.convertToBookCategory() })
        case .failure(let failure):
            MHLogger.debug("\(failure.description)")
            return .failure(failure)
        }
    }
    
    public func updateBookCategory(oldName: String, with category: BookCategory) async -> Result<Void, MHDataError> {
        return await storage.update(
            oldName: oldName,
            with: BookCategoryDTO(order: category.order, name: category.name)
        )
    }
    
    public func deleteBookCategory(with categoryName: String) async -> Result<Void, MHDataError> {
        return await storage.delete(with: categoryName)
    }
}
