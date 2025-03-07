import Foundation

public struct DefaultCreateBookCoverUseCase: CreateBookCoverUseCase {
    private let repository: BookCoverRepository
    
    public init(repository: BookCoverRepository) {
        self.repository = repository
    }
    
    public func execute(with bookCover: BookCover) throws {
        try repository.createBookCover(with: bookCover)
    }
}

public struct DefaultFetchBookCoverUseCase: FetchBookCoverUseCase {
    private let repository: BookCoverRepository
    
    public init(repository: BookCoverRepository) {
        self.repository = repository
    }
    
    public func execute(id: UUID) throws -> BookCover? {
        try repository.fetchBookCover(with: id)
    }
}

public struct DefaultFetchAllBookCoverUseCase: FetchAllBookCoverUseCase {
    private let repository: BookCoverRepository
    
    public init(repository: BookCoverRepository) {
        self.repository = repository
    }
    
    public func execute() throws -> [BookCover] {
        try repository.fetchAllBookCovers()
    }
}

public struct DefaultUpdateBookCoverUseCase: UpdateBookCoverUseCase {
    private let repository: BookCoverRepository
    
    public init(repository: BookCoverRepository) {
        self.repository = repository
    }
    
    public func execute(id: UUID, with bookCover: BookCover) throws {
        try repository.updateBookCover(id: id, with: bookCover)
    }
}

public struct DefaultDeleteBookCoverUseCase: DeleteBookCoverUseCase {
    private let repository: BookCoverRepository
    
    public init(repository: BookCoverRepository) {
        self.repository = repository
    }
    
    public func execute(id: UUID) throws {
        try repository.deleteBookCover(id: id)
    }
}
