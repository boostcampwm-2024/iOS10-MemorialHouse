import MHFoundation

public protocol CreateMediaUseCase {
    func execute(media: MediaDescription, data: Data) async throws
    func execute(media: MediaDescription, in url: URL) async throws
}

public protocol FetchMediaUseCase {
    func execute(media: MediaDescription, in bookID: UUID) async throws -> Data
    func execute(media: MediaDescription, in bookID: UUID) async throws -> URL
}

public protocol DeleteMediaUseCase {
    func execute(media: MediaDescription, in bookID: UUID) async throws
}

public protocol PersistentlyStoreMediaUseCase {
    func execute(to bookID: UUID) async throws
}
