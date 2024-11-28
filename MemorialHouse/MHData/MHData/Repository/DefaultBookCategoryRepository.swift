import MHCore
import MHDomain

public struct DefaultBookCategoryRepository: BookCategoryRepository {    
    private let storage: BookCategoryStorage
    
    public init(storage: BookCategoryStorage) {
        self.storage = storage
    }
    
    public func createBookCategory(name: String) async -> Result<Void, MHDataError> {
        return await storage.create(with: BookCategoryDTO(order: 0, name: name))
    }
    
    public func fetchBookCategories() async -> Result<[String], MHDataError> {
        return .success(["가족", "친구", "영카소와 아이들"])
    }
    
    public func updateBookCategory(oldName: String, newName: String) async -> Result<Void, MHDataError> {
        return .success(())
    }
    
    public func deleteBookCategory(name: String) async -> Result<Void, MHDataError> {
        return .success(())
    }
}
