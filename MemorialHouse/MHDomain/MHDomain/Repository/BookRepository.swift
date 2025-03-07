import Foundation
import MHCore

public protocol BookRepository: Sendable {
    func create(book: Book) throws
    func fetch(bookID id: UUID) throws -> Book
    func update(bookID id: UUID, to book: Book) throws
    func delete(bookID id: UUID) throws
}
