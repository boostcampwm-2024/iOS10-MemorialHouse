import Foundation
import Photos
import MHDomain
import MHCore
import AVFoundation

public struct LocalMediaRepository: MediaRepository, Sendable {
    private let storage: FileStorage
    private let temporaryPath = "temporary"
    private let snapshotFileName = ".snapshot"
    
    public init(storage: FileStorage) {
        self.storage = storage
    }
    
    public func create(media mediaDescription: MediaDescription, data: Data, to bookID: UUID?) throws {
        let path = bookID == nil
        ? temporaryPath
        : bookID!.uuidString
        let fileName = fileName(of: mediaDescription)
        
        try storage.create(at: path, fileName: fileName, data: data)
    }
    
    public func create(media mediaDescription: MediaDescription, from: URL, to bookID: UUID?) throws {
        let path = bookID == nil
        ? temporaryPath
        : bookID!.uuidString
        let fileName = fileName(of: mediaDescription)
        
        try storage.copy(at: from, to: path, newFileName: fileName)
    }
    
    public func fetch(media mediaDescription: MediaDescription, from bookID: UUID?) throws -> Data {
        let path = bookID == nil
        ? temporaryPath
        : bookID!.uuidString
        let fileName = fileName(of: mediaDescription)
        
        return try storage.read(at: path, fileName: fileName)
    }
    
    public func delete(media mediaDescription: MediaDescription, at bookID: UUID?) throws {
        let path = bookID == nil
        ? temporaryPath
        : bookID!.uuidString
        let fileName = fileName(of: mediaDescription)
        
        try storage.delete(at: path, fileName: fileName)
    }
    
    public func moveTemporaryMedia(_ mediaDescription: MediaDescription, to bookID: UUID) throws {
        let path = bookID.uuidString
        let fileName = fileName(of: mediaDescription)
        
        try storage.move(at: temporaryPath, fileName: fileName, to: path)
    }
    
    public func getURL(media mediaDescription: MediaDescription, from bookID: UUID?) throws -> URL {
        let path = bookID == nil
        ? temporaryPath
        : bookID!.uuidString
        let fileName = fileName(of: mediaDescription)
        
        return try storage.getURL(at: path, fileName: fileName)
    }
    
    public func makeTemporaryDirectory() throws {
        try storage.makeDirectory(through: temporaryPath)
    }
    
    public func moveAllTemporaryMedia(to bookID: UUID) throws {
        let path = bookID.uuidString
        
        try storage.moveAll(in: temporaryPath, to: path)
    }
    
    // MARK: - Snpashot
    public func createSnapshot(for media: [MediaDescription], in bookID: UUID) throws {
        let path = bookID.uuidString
        let mediaList = media.map { fileName(of: $0) }
        guard let snapshot = try? JSONEncoder().encode(mediaList)
        else { throw MHDataError.snapshotEncodingFailure }
        
        try storage.create(at: path, fileName: snapshotFileName, data: snapshot)
    }
    
    public func deleteMediaBySnapshot(for bookID: UUID) throws {
        let path = bookID.uuidString
        let snapshotData = try storage.read(at: path, fileName: snapshotFileName)
        let mediaSet = Set<String>(try JSONDecoder().decode([String].self, from: snapshotData))
        // snapshot 파일은 제외
        let currentFiles = Set<String>(try storage.getFileNames(at: path)).subtracting([snapshotFileName])
        let shouldDelete = currentFiles.subtracting(mediaSet)
        for fileName in shouldDelete {
            _ = try storage.delete(at: path, fileName: fileName)
        }
    }
    
    // MARK: - Helper
    private func fileName(of media: MediaDescription) -> String {
        return media.id.uuidString + media.type.defaultFileExtension
    }
}
