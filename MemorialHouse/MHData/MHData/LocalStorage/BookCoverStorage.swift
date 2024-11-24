import MHFoundation
import MHCore

public protocol BookCoverStorage {
    func fetch() async -> Result<[BookCoverDTO], MHError>
    func create(data: BookCoverDTO) async -> Result<Void, MHError>
    func update(with id: UUID, data: BookCoverDTO) async -> Result<Void, MHError>
    func delete(with id: UUID) async -> Result<Void, MHError>
}
