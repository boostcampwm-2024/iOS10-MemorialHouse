import MHFoundation
import MHCore

public protocol CoreDataSource<DTO> {
    associatedtype DTO
    
    func fetch() async -> Result<[DTO], MHError>
    @discardableResult func create(data: DTO) async -> Result<Void, MHError>
    @discardableResult func update(with id: UUID, data: DTO) async -> Result<Void, MHError>
    @discardableResult func delete(with id: UUID) async -> Result<Void, MHError>
}
