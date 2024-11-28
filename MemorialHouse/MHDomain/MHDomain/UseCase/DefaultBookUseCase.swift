import MHFoundation

public struct DefaultCreateBookUseCase: CreateBookUseCase {
    // MARK: - Property
    let repository: BookRepository
    
    // MARK: - Initializer
    public init(repository: BookRepository) {
        self.repository = repository
    }
    
    // MARK: - Method
    public func execute(book: Book) async throws {
        try await repository.create(book: book).get()
    }
}

public struct DefaultFetchBookUseCase: FetchBookUseCase {
    // MARK: - Property
    let repository: BookRepository
    
    // MARK: - Initializer
    public init(repository: BookRepository) {
        self.repository = repository
    }
    
    // MARK: - Method
    public func execute(bookID: UUID) async throws -> Book {
        try await repository.fetch(bookID: bookID).get()
    }
}

public struct DefaultUpdateBookUseCase: UpdateBookUseCase {
    // MARK: - Property
    let repository: BookRepository
    
    // MARK: - Initializer
    public init(repository: BookRepository) {
        self.repository = repository
    }
    
    // MARK: - Method
    public func execute(book: Book) async throws {
        try await repository.update(bookID: book.id, to: book).get()
    }
}

public struct DefaultDeleteBookUseCase: DeleteBookUseCase {
    // MARK: - Property
    let repository: BookRepository
    
    // MARK: - Initializer
    public init(repository: BookRepository) {
        self.repository = repository
    }
    
    // MARK: - Method
    public func execute(bookID: UUID) async throws {
        try await repository.delete(bookID: bookID).get()
    }
}
