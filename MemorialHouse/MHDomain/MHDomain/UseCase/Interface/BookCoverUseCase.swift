import MHFoundation

public protocol CreateBookCoverUseCase: Sendable {
    func execute(with bookCover: BookCover) async throws
}

public protocol FetchBookCoverUseCase: Sendable {
    func execute(id: UUID) async throws -> BookCover?
}

public protocol FetchAllBookCoverUseCase: Sendable {
    func execute() async throws -> [BookCover]
}

public protocol UpdateBookCoverUseCase: Sendable {
    func execute(id: UUID, with bookCover: BookCover) async throws
}

public protocol DeleteBookCoverUseCase: Sendable {
    func execute(id: UUID) async throws
}
