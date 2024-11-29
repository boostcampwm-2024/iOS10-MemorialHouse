import MHFoundation
import MHCore

public protocol BookRepository: Sendable {
    func create(book: Book) async -> Result<Void, MHDataError>
    func fetch(bookID id: UUID) async -> Result<Book, MHDataError>
    func update(bookID id: UUID, to book: Book) async -> Result<Void, MHDataError>
    func delete(bookID id: UUID) async -> Result<Void, MHDataError>
}
