import Foundation
import MHCore

public protocol BookCoverStorage: Sendable {
    func create(data: BookCoverDTO) throws
    func fetch() throws -> [BookCoverDTO]
    func update(with id: UUID, data: BookCoverDTO) throws
    func delete(with id: UUID) throws
}
