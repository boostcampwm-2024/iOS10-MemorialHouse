import MHFoundation
import MHCore

public protocol BookRepository {
    func create(book: Book) async -> Result<Void, MHError>
    func fetch(bookID id: UUID) async -> Result<Book, MHError>
    func update(bookID id: UUID, to book: Book) async -> Result<Void, MHError>
    func delete(bookID id: UUID) async -> Result<Void, MHError>
}
