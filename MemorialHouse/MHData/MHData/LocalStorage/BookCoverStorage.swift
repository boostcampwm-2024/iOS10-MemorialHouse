import Foundation
import MHCore

public protocol BookCoverStorage: Sendable {
    func create(data: BookCoverDTO) async throws
    func fetch() async throws -> [BookCoverDTO]
    func update(with id: UUID, data: BookCoverDTO) async throws
    func delete(with id: UUID) async throws
}
