import MHFoundation

public protocol BookRepository {
    func create(book: Book) async
    func fetchBook(with id: UUID) async -> Book?
    func update(id: UUID, book: Book) async
    func deleteBook(_ id: UUID) async
}
