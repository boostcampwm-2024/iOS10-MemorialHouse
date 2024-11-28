import MHFoundation
import MHCore

public protocol BookCategoryStorage: Sendable {
    func create(with category: BookCategoryDTO) async -> Result<Void, MHDataError>
    func fetch() async -> Result<[BookCategoryDTO], MHDataError>
    func update(with category: BookCategoryDTO) async -> Result<Void, MHDataError>
    func delete(with categoryName: String) async -> Result<Void, MHDataError>
}
