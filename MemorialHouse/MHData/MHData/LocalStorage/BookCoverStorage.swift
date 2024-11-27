import MHFoundation
import MHCore

public protocol BookCoverStorage {
    func create(data: BookCoverDTO) async -> Result<Void, MHDataError>
    func fetch() async -> Result<[BookCoverDTO], MHDataError>
    func update(with id: UUID, data: BookCoverDTO) async -> Result<Void, MHDataError>
    func delete(with id: UUID) async -> Result<Void, MHDataError>
}
