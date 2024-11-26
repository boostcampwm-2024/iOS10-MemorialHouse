import MHFoundation
import MHCore

public protocol PageStrorage {
    func create(data: PageDTO) async -> Result<Void, MHError>
    func fetch() async -> Result<[PageDTO], MHError>
    func update(with id: UUID, data: PageDTO) async -> Result<Void, MHError>
    func delete(with id: UUID) async -> Result<Void, MHError>
}
