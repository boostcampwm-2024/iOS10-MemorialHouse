import Foundation

public protocol CreateBookUseCase: Sendable {
    func execute(book: Book) throws
}

public protocol FetchBookUseCase: Sendable {
    func execute(id: UUID) throws -> Book
}

public protocol UpdateBookUseCase: Sendable {
    func execute(id: UUID, book: Book) throws
}

public protocol DeleteBookUseCase: Sendable {
    func execute(id: UUID) throws
}
