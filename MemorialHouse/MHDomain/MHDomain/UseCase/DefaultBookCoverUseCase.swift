import Foundation

public struct DefaultCreateBookCoverUseCase: CreateBookCoverUseCase {
    private let repository: BookCoverRepository
    
    public init(repository: BookCoverRepository) {
        self.repository = repository
    }
    
    public func execute(with bookCover: BookCover) async throws {
        try await repository.createBookCover(with: bookCover)
    }
}

public struct DefaultFetchBookCoverUseCase: FetchBookCoverUseCase {
    private let repository: BookCoverRepository
    
    public init(repository: BookCoverRepository) {
        self.repository = repository
    }
    
    public func execute(id: UUID) async throws -> BookCover? {
        try await repository.fetchBookCover(with: id)
    }
}

public struct DefaultFetchAllBookCoverUseCase: FetchAllBookCoverUseCase {
    private let repository: BookCoverRepository
    
    public init(repository: BookCoverRepository) {
        self.repository = repository
    }
    
    public func execute() async throws -> [BookCover] {
        try await repository.fetchAllBookCovers()
    }
}

public struct DefaultUpdateBookCoverUseCase: UpdateBookCoverUseCase {
    private let repository: BookCoverRepository
    
    public init(repository: BookCoverRepository) {
        self.repository = repository
    }
    
    public func execute(id: UUID, with bookCover: BookCover) async throws {
        try await repository.updateBookCover(id: id, with: bookCover)
    }
}

public struct DefaultDeleteBookCoverUseCase: DeleteBookCoverUseCase {
    private let repository: BookCoverRepository
    
    public init(repository: BookCoverRepository) {
        self.repository = repository
    }
    
    public func execute(id: UUID) async throws {
        try await repository.deleteBookCover(id: id)
    }
}
