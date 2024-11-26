import MHFoundation

public protocol BookRepository {
    func create(book: Book) async
    func fetch(bookID id: UUID) async -> Book?
    func update(bookID id: UUID, to book: Book) async
    func delete(bookID id: UUID) async
}
