import MHFoundation

public protocol CreateBookUseCase: Sendable {
    func execute(book: Book) async throws
}
public protocol FetchBookUseCase: Sendable {
    func execute(bookID: UUID) async throws -> Book
}
public protocol UpdateBookUseCase: Sendable {
    func execute(book: Book) async throws
}
public protocol DeleteBookUseCase: Sendable {
    func execute(bookID: UUID) async throws
}
