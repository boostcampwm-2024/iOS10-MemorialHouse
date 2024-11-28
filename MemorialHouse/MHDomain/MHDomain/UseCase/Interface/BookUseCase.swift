import MHFoundation

public protocol CreateBookUseCase {
    func execute(book: Book) async throws
}

public protocol FetchBookUseCase {
    func execute(id: UUID) async throws -> Book
}

public protocol UpdateBookUseCase {
    func execute(id: UUID, book: Book) async throws
}

public protocol DeleteBookUseCase {
    func execute(id: UUID) async throws
}
