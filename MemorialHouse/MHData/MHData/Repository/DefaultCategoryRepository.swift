import MHDomain

public struct DefaultCategoryRepository: CategoryRepository {
    public init() { }
    
    public func createCategory(name: String) async -> Result<Void, any Error> {
        return .success(())
    }
    
    public func fetchCategories() async -> Result<[String], any Error> {
        return .success(["가족", "친구", "영카소와 아이들"])
    }
    
    public func updateCategory(oldName: String, newName: String) async -> Result<Void, any Error> {
        return .success(())
    }
    
    public func deleteCategory(name: String) async -> Result<Void, any Error> {
        return .success(())
    }
}
