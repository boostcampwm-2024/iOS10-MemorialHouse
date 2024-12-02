import MHFoundation

public struct DefaultCreateBookUseCase: CreateBookUseCase {
    private let repository: BookRepository
    private let mediaRepository: MediaRepository
    
    public init(repository: BookRepository, mediaRepository: MediaRepository) {
        self.repository = repository
        self.mediaRepository = mediaRepository
    }
    
    public func execute(book: Book) async throws {
        try await repository.create(book: book).get()
        try await mediaRepository.createSnapshot(for: [], in: book.id).get()
    }
}

public struct DefaultFetchBookUseCase: FetchBookUseCase {
    private let repository: BookRepository
    
    public init(repository: BookRepository) {
        self.repository = repository
    }
    
    public func execute(id: UUID) async throws -> Book {
        try await repository.fetch(bookID: id).get()
    }
}

public struct DefaultUpdateBookUseCase: UpdateBookUseCase {
    private let repository: BookRepository
    
    public init(repository: BookRepository) {
        self.repository = repository
    }
    
    public func execute(id: UUID, book: Book) async throws {
        try await repository.update(bookID: id, to: book).get()
    }
}

public struct DefaultDeleteBookUseCase: DeleteBookUseCase {
    private let repository: BookRepository
    
    public init(repository: BookRepository) {
        self.repository = repository
    }
    
    public func execute(id: UUID) async throws {
        try await repository.delete(bookID: id).get()
    }
}
