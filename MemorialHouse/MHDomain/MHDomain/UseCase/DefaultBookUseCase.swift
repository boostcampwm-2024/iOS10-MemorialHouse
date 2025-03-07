import Foundation

public struct DefaultCreateBookUseCase: CreateBookUseCase {
    private let repository: BookRepository
    private let mediaRepository: MediaRepository
    
    public init(repository: BookRepository, mediaRepository: MediaRepository) {
        self.repository = repository
        self.mediaRepository = mediaRepository
    }
    
    public func execute(book: Book) throws {
        try repository.create(book: book)
        try mediaRepository.createSnapshot(for: [], in: book.id)
    }
}

public struct DefaultFetchBookUseCase: FetchBookUseCase {
    private let repository: BookRepository
    
    public init(repository: BookRepository) {
        self.repository = repository
    }
    
    public func execute(id: UUID) throws -> Book {
        try repository.fetch(bookID: id)
    }
}

public struct DefaultUpdateBookUseCase: UpdateBookUseCase {
    private let repository: BookRepository
    
    public init(repository: BookRepository) {
        self.repository = repository
    }
    
    public func execute(id: UUID, book: Book) throws {
        try repository.update(bookID: id, to: book)
    }
}

public struct DefaultDeleteBookUseCase: DeleteBookUseCase {
    private let repository: BookRepository
    
    public init(repository: BookRepository) {
        self.repository = repository
    }
    
    public func execute(id: UUID) throws {
        try repository.delete(bookID: id)
    }
}
