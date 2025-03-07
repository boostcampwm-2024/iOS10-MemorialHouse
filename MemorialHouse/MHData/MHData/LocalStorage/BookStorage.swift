import Foundation
import MHCore

public protocol BookStorage: Sendable {
    func create(data: BookDTO) async throws
    func fetch(with id: UUID) async throws -> BookDTO
    func update(with id: UUID, data: BookDTO) async throws
    func delete(with id: UUID) async throws
}
