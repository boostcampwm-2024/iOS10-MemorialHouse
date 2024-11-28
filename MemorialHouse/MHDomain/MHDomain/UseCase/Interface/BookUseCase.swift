import MHFoundation

public protocol CreateBookUseCase {
    func execute(book: Book) async throws
}
public protocol FetchBookUseCase {
    func execute(bookID: UUID) async throws -> Book
}
public protocol UpdateBookUseCase {
    func execute(book: Book) async throws
}
public protocol DeleteBookUseCase {
    func execute(bookID: UUID) async throws
}
