import MHFoundation
import MHCore
import MHDomain

public struct MHFileManager {
    private let fileManager = FileManager.default
    private let directoryType: FileManager.SearchPathDirectory
    
    public init(directoryType: FileManager.SearchPathDirectory) {
        self.directoryType = directoryType
    }
}

extension MHFileManager: FileStorage {
    func create(at path: String, fileName name: String, data: Data) async -> Result<Void, MHError> {
        guard let directory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: path)
        else { return .failure(.directorySettingFailure) }
        
        let dataPath = directory.appendingPathComponent(name)
        
        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            try data.write(to: dataPath)
            return .success(())
        } catch {
            return .failure(.fileCreationFailure)
        }
    }
    func read(at path: String, fileName name: String) async -> Result<Data, MHError> {
        guard let directory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: path)
        else { return .failure(.directorySettingFailure) }
        
        let dataPath = directory.appendingPathComponent(name)
        
        do {
            return .success(try Data(contentsOf: dataPath))
        } catch {
            return .failure(.fileReadingFailure)
        }
    }
    func delete(at path: String, fileName name: String) async -> Result<Void, MHError> {
        guard let directory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: path)
        else { return .failure(.directorySettingFailure) }
        
        let dataPath = directory.appendingPathComponent(name)
        
        do {
            try fileManager.removeItem(at: dataPath)
            return .success(())
        } catch {
            return .failure(.fileDeletionFailure)
        }
    }
    func move(at path: String, fileName name: String, to newPath: String) async -> Result<Void, MHError> {
        guard let originDirectory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: path)
        else { return .failure(.directorySettingFailure) }
        
        let originDataPath = originDirectory.appendingPathComponent(name)
        
        guard let newDirectory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: newPath)
        else { return .failure(.directorySettingFailure) }
        
        let newDataPath = newDirectory.appendingPathComponent(name)
        
        do {
            try fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: true)
            try fileManager.moveItem(at: originDataPath, to: newDataPath)
            return .success(())
        } catch {
            return .failure(.fileMovingFailure)
        }
    }
}
