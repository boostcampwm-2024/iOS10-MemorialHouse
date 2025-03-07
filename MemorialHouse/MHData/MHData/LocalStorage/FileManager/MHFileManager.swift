import Foundation
import MHCore

public struct MHFileManager: Sendable {
    private var fileManager: FileManager { FileManager.default }
    private let directoryType: FileManager.SearchPathDirectory
    
    public init(directoryType: FileManager.SearchPathDirectory) {
        self.directoryType = directoryType
    }
}

extension MHFileManager: FileStorage {
    public func create(at path: String, fileName name: String, data: Data) throws {
        guard let directory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: path)
        else { throw MHDataError.directorySettingFailure }
        
        let dataPath = directory.appendingPathComponent(name)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: dataPath, options: .atomic)
    }
    
    public func read(at path: String, fileName name: String) throws -> Data {
        guard let directory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: path)
        else { throw MHDataError.directorySettingFailure }
        
        let dataPath = directory.appendingPathComponent(name)
        
        guard fileManager.fileExists(atPath: dataPath.path) else { throw MHDataError.fileNotExists }
        return try Data(contentsOf: dataPath)
    }
    
    public func delete(at path: String, fileName name: String) throws {
        guard let directory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: path)
        else { throw MHDataError.directorySettingFailure }
        
        let dataPath = directory.appendingPathComponent(name)
        try fileManager.removeItem(at: dataPath)
    }
    
    public func copy(at url: URL, to newPath: String, newFileName name: String) throws {
        let originDataPath = url
        
        guard fileManager.fileExists(atPath: originDataPath.path) else { throw MHDataError.fileNotExists }
        
        guard let newDirectory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: newPath)
        else { throw MHDataError.directorySettingFailure }
        
        let newDataPath = newDirectory.appendingPathComponent(name)
        MHLogger.debug("\(#function) \(newDataPath)")
        
        try fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: true)
        try fileManager.copyItem(at: originDataPath, to: newDataPath)
    }
    
    public func copy(at path: String, fileName name: String, to newPath: String) throws {
        guard let originDirectory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: path)
        else { throw MHDataError.directorySettingFailure }
        
        let originDataPath = originDirectory.appendingPathComponent(name)
        
        guard fileManager.fileExists(atPath: originDataPath.path) else { throw MHDataError.fileNotExists }
        
        guard let newDirectory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: newPath)
        else { throw MHDataError.directorySettingFailure }
        
        let newDataPath = newDirectory.appendingPathComponent(name)
        try fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: true)
        try fileManager.copyItem(at: originDataPath, to: newDataPath)
    }
    
    public func move(at path: String, fileName name: String, to newPath: String) throws {
        guard let originDirectory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: path)
        else { throw MHDataError.directorySettingFailure }
        
        let originDataPath = originDirectory.appendingPathComponent(name)
        
        guard fileManager.fileExists(atPath: originDataPath.path) else { throw MHDataError.fileNotExists }
        
        guard let newDirectory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: newPath)
        else { throw MHDataError.directorySettingFailure }
        
        let newDataPath = newDirectory.appendingPathComponent(name)
        try fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: true)
        try fileManager.moveItem(at: originDataPath, to: newDataPath)
    }
    
    public func moveAll(in path: String, to newPath: String) throws {
        guard let originDirectory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: path)
        else { throw MHDataError.directorySettingFailure }
        
        guard fileManager.fileExists(atPath: originDirectory.path) else { throw MHDataError.fileNotExists }
        
        guard let newDirectory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: newPath)
        else { throw MHDataError.directorySettingFailure }
        let files = try fileManager.contentsOfDirectory(atPath: originDirectory.path)
        try fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: true)
        for file in files {
            let originDataPath = originDirectory.appendingPathComponent(file)
            let newDataPath = newDirectory.appendingPathComponent(file)
            try fileManager.moveItem(at: originDataPath, to: newDataPath)
        }
    }
    
    public func getURL(at path: String, fileName name: String) throws -> URL {
        guard let originDirectory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: path)
        else { throw MHDataError.directorySettingFailure }
        
        return originDirectory.appendingPathComponent(name)
    }
    
    public func makeDirectory(through path: String) throws {
        guard let originDirectory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: path)
        else { throw MHDataError.directorySettingFailure }
        guard (
            try? fileManager.createDirectory(
                at: originDirectory,
                withIntermediateDirectories: true
            )
        ) != nil else { throw MHDataError.directorySettingFailure }
    }
    
    public func getFileNames(at path: String) throws -> [String] {
        guard let originDirectory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: path)
        else { throw MHDataError.directorySettingFailure }
        return try fileManager.contentsOfDirectory(atPath: originDirectory.path)
    }
}
