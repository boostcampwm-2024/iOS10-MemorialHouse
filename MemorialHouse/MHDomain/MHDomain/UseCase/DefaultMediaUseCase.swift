import MHFoundation
import MHCore

public struct DefaultCreateMediaUseCase: CreateMediaUseCase, Sendable {
    // MARK: - Property
    let repository: MediaRepository
    
    // MARK: - Initializer
    public init(repository: MediaRepository) {
        self.repository = repository
    }
    
    // MARK: - Method
    public func execute(media: MediaDescription, data: Data, at bookID: UUID?) async throws {
        try await repository.create(media: media, data: data, to: bookID).get()
    }
    public func execute(media: MediaDescription, from url: URL, at bookID: UUID?) async throws {
        try await repository.create(media: media, from: url, to: bookID).get()
    }
}

public struct DefaultFetchMediaUseCase: FetchMediaUseCase {
    // MARK: - Property
    let repository: MediaRepository
    
    // MARK: - Initializer
    public init(repository: MediaRepository) {
        self.repository = repository
    }
    
    // MARK: - Method
    public func execute(media: MediaDescription, in bookID: UUID) async throws -> Data {
        try await repository.fetch(media: media, from: bookID).get()
    }
    public func execute(media: MediaDescription, in bookID: UUID) async throws -> URL {
        try await repository.getURL(media: media, from: bookID).get()
    }
}

public struct DefaultDeleteMediaUseCase: DeleteMediaUseCase {
    // MARK: - Property
    let repository: MediaRepository
    
    // MARK: - Initializer
    public init(repository: MediaRepository) {
        self.repository = repository
    }
    
    // MARK: - Method
    public func execute(media: MediaDescription, in bookID: UUID) async throws {
        do {
            return try await repository.delete(media: media, at: nil).get() // TODO: - 없어질 로직
        } catch {
            return try await repository.delete(media: media, at: bookID).get()
        }
    }
}

public struct DefaultPersistentlyStoreMediaUseCase: PersistentlyStoreMediaUseCase {
    
    // MARK: - Property
    let repository: MediaRepository
    
    // MARK: - Initializer
    public init(repository: MediaRepository) {
        self.repository = repository
    }
    
    // MARK: - Method
    public func execute(to bookID: UUID) async throws { // TODO: - 없어질 로직
        try await repository.moveAllTemporaryMedia(to: bookID).get()
    }
    public func execute(to bookID: UUID, mediaList: [MediaDescription]?) async throws {
        if let mediaList {
            try await repository.createSnapshot(for: mediaList, in: bookID).get()
        }
        
        try await repository.deleteMediaBySnapshot(for: bookID).get()
    }
    
    public func excute(media: MediaDescription, to bookID: UUID) async throws {
        try await repository.moveTemporaryMedia(media, to: bookID).get()
    }
    
}

public struct DefaultTemporaryStoreMediaUseCase: TemporaryStoreMediaUseCase {
    // MARK: - Property
    let repository: MediaRepository
    
    // MARK: - Initializer
    public init(repository: MediaRepository) {
        self.repository = repository
    }
    
    // MARK: - Method
    public func execute(media: MediaDescription) async throws -> URL {
        try await repository.makeTemporaryDirectory().get()
        return try await repository.getURL(media: media, from: nil).get()
    }
}
