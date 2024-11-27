import MHFoundation
import MHCore
import Photos

public protocol MediaRepository {
    func create(media mediaDescription: MediaDescription, data: Data, to bookID: UUID?) async -> Result<Void, MHError>
    func create(media mediaDescription: MediaDescription, from: URL, to bookID: UUID?) async -> Result<Void, MHError>
    func read(media mediaDescription: MediaDescription, from bookID: UUID?) async -> Result<Data, MHError>
    func getURL(media mediaDescription: MediaDescription, from bookID: UUID?) async -> Result<URL, MHError>
    func delete(media mediaDescription: MediaDescription, at bookID: UUID?) async -> Result<Void, MHError>
    func moveTemporaryMedia(_ mediaDescription: MediaDescription, to bookID: UUID) async -> Result<Void, MHError>
    func moveAllTemporaryMedia(to bookID: UUID) async -> Result<Void, MHError>
}
