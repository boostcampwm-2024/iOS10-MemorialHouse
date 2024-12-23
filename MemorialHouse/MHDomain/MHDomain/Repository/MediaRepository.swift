import MHFoundation
import MHCore

public protocol MediaRepository: Sendable {
    func create(media mediaDescription: MediaDescription, data: Data, to bookID: UUID?) async -> Result<Void, MHDataError>
    func create(media mediaDescription: MediaDescription, from: URL, to bookID: UUID?) async -> Result<Void, MHDataError>
    func fetch(media mediaDescription: MediaDescription, from bookID: UUID?) async -> Result<Data, MHDataError>
    func getURL(media mediaDescription: MediaDescription, from bookID: UUID?) async -> Result<URL, MHDataError>
    func makeTemporaryDirectory() async -> Result<Void, MHDataError>
    func delete(media mediaDescription: MediaDescription, at bookID: UUID?) async -> Result<Void, MHDataError>
    func moveTemporaryMedia(_ mediaDescription: MediaDescription, to bookID: UUID) async -> Result<Void, MHDataError>
    func moveAllTemporaryMedia(to bookID: UUID) async -> Result<Void, MHDataError>
    
    // MARK: - Snapshot
    func createSnapshot(for media: [MediaDescription], in bookID: UUID) async -> Result<Void, MHDataError>
    func deleteMediaBySnapshot(for bookID: UUID) async -> Result<Void, MHDataError>
}
