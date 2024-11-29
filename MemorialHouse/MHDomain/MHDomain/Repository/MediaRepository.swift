import MHFoundation
import MHCore
import Photos

public protocol MediaRepository: Sendable {
    func create(media mediaDescription: MediaDescription, data: Data, to bookID: UUID?) async -> Result<Void, MHDataError>
    func create(media mediaDescription: MediaDescription, from: URL, to bookID: UUID?) async -> Result<Void, MHDataError>
    func read(media mediaDescription: MediaDescription, from bookID: UUID?) async -> Result<Data, MHDataError>
    func getURL(media mediaDescription: MediaDescription, from bookID: UUID?) async -> Result<URL, MHDataError>
    func delete(media mediaDescription: MediaDescription, at bookID: UUID?) async -> Result<Void, MHDataError>
    func moveTemporaryMedia(_ mediaDescription: MediaDescription, to bookID: UUID) async -> Result<Void, MHDataError>
    func moveAllTemporaryMedia(to bookID: UUID) async -> Result<Void, MHDataError>
}
