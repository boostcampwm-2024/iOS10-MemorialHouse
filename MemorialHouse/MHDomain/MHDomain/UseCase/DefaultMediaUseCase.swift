import Foundation
import MHCore

public struct DefaultCreateMediaUseCase: CreateMediaUseCase, Sendable {
    // MARK: - Property
    let repository: MediaRepository
    
    // MARK: - Initializer
    public init(repository: MediaRepository) {
        self.repository = repository
    }
    
    // MARK: - Method
    public func execute(media: MediaDescription, data: Data, at bookID: UUID?) throws {
        try repository.create(media: media, data: data, to: bookID)
    }
    
    public func execute(media: MediaDescription, from url: URL, at bookID: UUID?) throws {
        try repository.create(media: media, from: url, to: bookID)
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
    public func execute(media: MediaDescription, in bookID: UUID) throws -> Data {
        try repository.fetch(media: media, from: bookID)
    }
    
    public func execute(media: MediaDescription, in bookID: UUID) throws -> URL {
        try repository.getURL(media: media, from: bookID)
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
    public func execute(media: MediaDescription, in bookID: UUID) throws {
        try repository.delete(media: media, at: bookID)
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
    public func execute(to bookID: UUID) throws { // TODO: - 없어질 로직
        try repository.moveAllTemporaryMedia(to: bookID)
    }
    public func execute(to bookID: UUID, mediaList: [MediaDescription]?) throws {
        if let mediaList {
            try repository.createSnapshot(for: mediaList, in: bookID)
        }
        
        try repository.deleteMediaBySnapshot(for: bookID)
    }
    
    public func excute(media: MediaDescription, to bookID: UUID) throws {
        try repository.moveTemporaryMedia(media, to: bookID)
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
    public func execute(media: MediaDescription) throws -> URL {
        try repository.makeTemporaryDirectory()
        return try repository.getURL(media: media, from: nil)
    }
}

public struct DefaultDeleteTemporaryMediaUseCase: DeleteTemporaryMediaUseCase {
    // MARK: - Property
    let repository: MediaRepository
    
    // MARK: - Initializer
    public init(repository: MediaRepository) {
        self.repository = repository
    }
    
    // MARK: - Method
    public func execute(media: MediaDescription) throws {
        try repository.delete(media: media, at: nil)
    }
}
