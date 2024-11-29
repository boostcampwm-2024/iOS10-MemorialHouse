import MHFoundation

public protocol CreateBookUseCase: Sendable {
    func execute(book: Book) async throws
}

public protocol FetchBookUseCase: Sendable {
    func execute(id: UUID) async throws -> Book
}

public protocol UpdateBookUseCase: Sendable {
    func execute(id: UUID, book: Book) async throws
}

public protocol DeleteBookUseCase: Sendable {
    func execute(id: UUID) async throws
}
