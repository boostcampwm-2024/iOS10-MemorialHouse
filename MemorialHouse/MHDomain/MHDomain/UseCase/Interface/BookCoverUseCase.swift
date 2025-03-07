import Foundation

public protocol CreateBookCoverUseCase: Sendable {
    func execute(with bookCover: BookCover) throws
}

public protocol FetchBookCoverUseCase: Sendable {
    func execute(id: UUID) throws -> BookCover?
}

public protocol FetchAllBookCoverUseCase: Sendable {
    func execute() throws -> [BookCover]
}

public protocol UpdateBookCoverUseCase: Sendable {
    func execute(id: UUID, with bookCover: BookCover) throws
}

public protocol DeleteBookCoverUseCase: Sendable {
    func execute(id: UUID) throws
}
