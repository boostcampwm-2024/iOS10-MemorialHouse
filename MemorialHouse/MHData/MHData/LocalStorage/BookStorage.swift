import MHFoundation
import MHCore

public protocol BookStorage {
    func create(data: BookDTO) async -> Result<Void, MHError>
    func fetch(with id: UUID) async -> Result<BookDTO, MHError>
    func update(with id: UUID, data: BookDTO) async -> Result<Void, MHError>
    func delete(with id: UUID) async -> Result<Void, MHError>
}
