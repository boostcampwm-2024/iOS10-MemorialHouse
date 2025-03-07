import Foundation
import MHCore

public protocol MediaRepository: Sendable {
    func create(media mediaDescription: MediaDescription, data: Data, to bookID: UUID?) throws
    func create(media mediaDescription: MediaDescription, from: URL, to bookID: UUID?) throws
    func fetch(media mediaDescription: MediaDescription, from bookID: UUID?) throws -> Data
    func getURL(media mediaDescription: MediaDescription, from bookID: UUID?) throws -> URL
    func makeTemporaryDirectory() throws
    func delete(media mediaDescription: MediaDescription, at bookID: UUID?) throws
    func moveTemporaryMedia(_ mediaDescription: MediaDescription, to bookID: UUID) throws
    func moveAllTemporaryMedia(to bookID: UUID) throws
    
    // MARK: - Snapshot
    func createSnapshot(for media: [MediaDescription], in bookID: UUID) throws
    func deleteMediaBySnapshot(for bookID: UUID) throws
}
