import MHFoundation
import MHCore

public protocol BookCategoryStorage {
    func create(with data: BookCategoryDTO) async -> Result<Void, MHDataError>
    func fetch() async -> Result<[BookCategoryDTO], MHDataError>
    func update(with data: BookCategoryDTO) async -> Result<Void, MHDataError>
    func delete(with data: BookCategoryDTO) async -> Result<Void, MHDataError>
}
