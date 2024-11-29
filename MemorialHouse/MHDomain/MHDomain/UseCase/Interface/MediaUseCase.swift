import MHFoundation

public protocol CreateMediaUseCase: Sendable {
    func execute(media: MediaDescription, data: Data) async throws
    func execute(media: MediaDescription, in url: URL) async throws
}

public protocol FetchMediaUseCase: Sendable {
    func execute(media: MediaDescription, in bookID: UUID) async throws -> Data
    func execute(media: MediaDescription, in bookID: UUID) async throws -> URL
}

public protocol DeleteMediaUseCase: Sendable {
    func execute(media: MediaDescription, in bookID: UUID) async throws
}

public protocol PersistentlyStoreMediaUseCase: Sendable {
    func execute(to bookID: UUID) async throws
}
