import MHFoundation

public struct DefaultCreateBookCoverUseCase: CreateBookCoverUseCase {
    private let repository: BookCoverRepository
    
    public init(repository: BookCoverRepository) {
        self.repository = repository
    }
    
    public func execute(with bookCover: BookCover) async throws {
        try await repository.createBookCover(with: bookCover).get()
    }
}

public struct DefaultFetchBookCoverUseCase: FetchBookCoverUseCase {
    private let repository: BookCoverRepository
    
    public init(repository: BookCoverRepository) {
        self.repository = repository
    }
    
    public func execute(id: UUID) async throws -> BookCover? {
        try await repository.fetchBookCover(with: id).get()
    }
}

public struct DefaultFetchAllBookCoversUseCase: FetchAllBookCoverUseCase {
    private let repository: BookCoverRepository
    
    public init(repository: BookCoverRepository) {
        self.repository = repository
    }
    
    public func execute() async throws -> [BookCover] {
        try await repository.fetchAllBookCovers().get()
    }
}

public struct DefaultUpdateBookCoverUseCase: UpdateBookCoverUseCase {
    private let repository: BookCoverRepository
    
    public init(repository: BookCoverRepository) {
        self.repository = repository
    }
    
    public func execute(id: UUID, with bookCover: BookCover) async throws {
        try await repository.updateBookCover(id: id, with: bookCover).get()
    }
}

public struct DefaultDeleteBookCoverUseCase: DeleteBookCoverUseCase {
    private let repository: BookCoverRepository
    
    public init(repository: BookCoverRepository) {
        self.repository = repository
    }
    
    public func execute(id: UUID) async throws {
        try await repository.deleteBookCover(id: id).get()
    }
}
