import MHFoundation
import MHCore

public protocol BookStorage {
    func create(data: BookDTO) async -> Result<Void, MHDataError>
    func fetch(with id: UUID) async -> Result<BookDTO, MHDataError>
    func update(with id: UUID, data: BookDTO) async -> Result<Void, MHDataError>
    func delete(with id: UUID) async -> Result<Void, MHDataError>
}
