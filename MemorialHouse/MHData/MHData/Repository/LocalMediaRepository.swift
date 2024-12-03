import MHFoundation
import Photos
import MHDomain
import MHCore
import AVFoundation

public struct LocalMediaRepository: MediaRepository, Sendable {
    private let storage: FileStorage
    private let temporaryPath = "temp" // TODO: - 지워질 것임!
    private let snapshotFileName = ".snapshot"
    
    public init(storage: FileStorage) {
        self.storage = storage
    }
    
    public func create(
        media mediaDescription: MediaDescription,
        data: Data,
        to bookID: UUID?
    ) async -> Result<Void, MHDataError> {
        let path = bookID == nil
        ? temporaryPath
        : bookID!.uuidString
        let fileName = fileName(of: mediaDescription)
        
        return await storage.create(at: path, fileName: fileName, data: data)
    }
    
    public func create(
        media mediaDescription: MediaDescription,
        from: URL,
        to bookID: UUID?
    ) async -> Result<Void, MHDataError> {
        let path = bookID == nil
        ? temporaryPath
        : bookID!.uuidString
        let fileName = fileName(of: mediaDescription)
        
        return await storage.copy(at: from, to: path, newFileName: fileName)
    }
    
    public func fetch(
        media mediaDescription: MediaDescription,
        from bookID: UUID?
    ) async -> Result<Data, MHDataError> {
        let path = bookID == nil
        ? temporaryPath
        : bookID!.uuidString
        let fileName = fileName(of: mediaDescription)
        
        return await storage.read(at: path, fileName: fileName)
    }
    
    public func delete(
        media mediaDescription: MediaDescription,
        at bookID: UUID?
    ) async -> Result<Void, MHDataError> {
        let path = bookID == nil
        ? temporaryPath
        : bookID!.uuidString
        let fileName = fileName(of: mediaDescription)
        
        return await storage.delete(at: path, fileName: fileName)
    }
    
    public func moveTemporaryMedia(
        _ mediaDescription: MediaDescription,
        to bookID: UUID
    ) async -> Result<Void, MHDataError> {
        let path = bookID.uuidString
        let fileName = mediaDescription.id.uuidString
        
        return await storage.move(at: "temp", fileName: fileName, to: path)
    }
    
    public func getURL(
        media mediaDescription: MediaDescription,
        from bookID: UUID?
    ) async -> Result<URL, MHDataError> {
        let path = bookID == nil
        ? temporaryPath
        : bookID!.uuidString
        let fileName = fileName(of: mediaDescription)
        
        return await storage.getURL(at: path, fileName: fileName)
    }
    
    public func moveAllTemporaryMedia(to bookID: UUID) async -> Result<Void, MHDataError> {
        let path = bookID.uuidString
        
        return await storage.moveAll(in: temporaryPath, to: path)
    }
    
    // MARK: - Snpashot
    public func createSnapshot(for media: [MediaDescription], in bookID: UUID) async -> Result<Void, MHDataError> {
        let path = bookID.uuidString
        let mediaList = media.map { fileName(of: $0) }
        guard let snapshot = try? JSONEncoder().encode(mediaList)
        else { return .failure(.snapshotEncodingFailure) }
        
        return await storage.create(at: path, fileName: snapshotFileName, data: snapshot)
    }
    public func deleteMediaBySnapshot(for bookID: UUID) async -> Result<Void, MHDataError> {
        let path = bookID.uuidString
        
        do {
            let snapshotData = try await storage.read(at: path, fileName: snapshotFileName).get()
            let mediaSet = Set<String>(try JSONDecoder().decode([String].self, from: snapshotData))
            // snapshot 파일은 제외
            let currentFiles = Set<String>(try await storage.getFileNames(at: path).get()).subtracting([snapshotFileName])
            let shouldDelete = currentFiles.subtracting(mediaSet)
            for fileName in shouldDelete {
                _ = try await storage.delete(at: path, fileName: fileName).get()
            }
            return .success(())
        } catch let error as MHDataError {
            return .failure(error)
        } catch {
            return .failure(.generalFailure)
        }
    }
    // MARK: - Helper
    private func fileName(of media: MediaDescription) -> String {
        return media.id.uuidString + media.type.defaultFileExtension
    }
}
