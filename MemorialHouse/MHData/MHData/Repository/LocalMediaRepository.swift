import MHFoundation
import Photos
import MHDomain
import MHCore
import AVFoundation

public struct LocalMediaRepository: MediaRepository {
    
    private let storage: FileStorage
    
    public init(storage: FileStorage) {
        self.storage = storage
    }
    
    public func create(media mediaDescription: MediaDescription, data: Data, to bookID: UUID?) async -> Result<Void, MHDataError> {
        let path = bookID == nil
        ? "temp"
        : bookID!.uuidString
        let fileName = mediaDescription.id.uuidString
        
        return await storage.create(at: path, fileName: fileName, data: data)
    }
    public func create(media mediaDescription: MediaDescription, from: URL, to bookID: UUID?) async -> Result<Void, MHDataError> {
        let path = bookID == nil
        ? "temp"
        : bookID!.uuidString
        let fileName = mediaDescription.id.uuidString
        
        return await storage.copy(at: from, to: path, newFileName: fileName)
    }
    public func read(media mediaDescription: MediaDescription, from bookID: UUID?) async -> Result<Data, MHDataError> {
        let path = bookID == nil
        ? "temp"
        : bookID!.uuidString
        let fileName = mediaDescription.id.uuidString
        
        return await storage.read(at: path, fileName: fileName)
    }
    public func getURL(media mediaDescription: MediaDescription, from bookID: UUID?) async -> Result<URL, MHDataError> {
        let path = bookID == nil
        ? "temp"
        : bookID!.uuidString
        let fileName = mediaDescription.id.uuidString
        
        return await storage.getURL(at: path, fileName: fileName)
    }
    public func delete(media mediaDescription: MediaDescription, at bookID: UUID?) async -> Result<Void, MHDataError> {
        let path = bookID == nil
        ? "temp"
        : bookID!.uuidString
        let fileName = mediaDescription.id.uuidString
        
        return await storage.delete(at: path, fileName: fileName)
    }
    public func moveTemporaryMedia(_ mediaDescription: MediaDescription, to bookID: UUID) async -> Result<Void, MHDataError> {
        let path = bookID.uuidString
        let fileName = mediaDescription.id.uuidString
        
        return await storage.move(at: "temp", fileName: fileName, to: path)
    }
    public func moveAllTemporaryMedia(to bookID: UUID) async -> Result<Void, MHDataError> {
        let path = bookID.uuidString
        
        return await storage.moveAll(in: "temp", to: path)
    }
}
