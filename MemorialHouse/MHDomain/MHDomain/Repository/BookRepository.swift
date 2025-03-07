import Foundation
import MHCore

public protocol BookRepository: Sendable {
    func create(book: Book) async throws
    func fetch(bookID id: UUID) async throws -> Book
    func update(bookID id: UUID, to book: Book) async throws
    func delete(bookID id: UUID) async throws
}
