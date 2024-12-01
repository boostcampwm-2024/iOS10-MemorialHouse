import MHFoundation

public protocol CreateMediaUseCase: Sendable {
    func execute(media: MediaDescription, data: Data, at bookID: UUID?) async throws
    func execute(media: MediaDescription, from url: URL, at bookID: UUID?) async throws
}

public protocol FetchMediaUseCase: Sendable {
    func execute(media: MediaDescription, in bookID: UUID) async throws -> Data
    func execute(media: MediaDescription, in bookID: UUID) async throws -> URL
}

public protocol DeleteMediaUseCase: Sendable {
    func execute(media: MediaDescription, in bookID: UUID) async throws
}

public protocol PersistentlyStoreMediaUseCase: Sendable {
    @available(*, deprecated, message: "temp를 더이상 사용하지 않습니다.")
    func execute(to bookID: UUID) async throws
    func execute(to bookID: UUID, mediaList: [MediaDescription]) async throws
}
