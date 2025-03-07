import Foundation
import MHCore

public protocol BookStorage: Sendable {
    func create(data: BookDTO) throws
    func fetch(with id: UUID) throws -> BookDTO
    func update(with id: UUID, data: BookDTO) throws
    func delete(with id: UUID) throws
}
