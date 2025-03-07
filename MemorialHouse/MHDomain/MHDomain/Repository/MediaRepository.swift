import Foundation
import MHCore

public protocol MediaRepository: Sendable {
    func create(media mediaDescription: MediaDescription, data: Data, to bookID: UUID?) async throws
    func create(media mediaDescription: MediaDescription, from: URL, to bookID: UUID?) async throws
    func fetch(media mediaDescription: MediaDescription, from bookID: UUID?) async throws -> Data
    func getURL(media mediaDescription: MediaDescription, from bookID: UUID?) async throws -> URL
    func makeTemporaryDirectory() async throws
    func delete(media mediaDescription: MediaDescription, at bookID: UUID?) async throws
    func moveTemporaryMedia(_ mediaDescription: MediaDescription, to bookID: UUID) async throws
    func moveAllTemporaryMedia(to bookID: UUID) async throws
    
    // MARK: - Snapshot
    func createSnapshot(for media: [MediaDescription], in bookID: UUID) async throws
    func deleteMediaBySnapshot(for bookID: UUID) async throws
}
