import MHFoundation
import MHCore

struct MHFileManager {
    private let fileManager = FileManager.default
    private let directoryType: FileManager.SearchPathDirectory
    
    init(directoryType: FileManager.SearchPathDirectory) {
        self.directoryType = directoryType
    }
}

extension MHFileManager: FileStorage {
    func create(at path: String, fileName name: String, data: Data) async -> Result<Void, MHDataError> {
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
    func read(at path: String, fileName name: String) async -> Result<Data, MHDataError> {
        guard let directory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: path)
        else { return .failure(.directorySettingFailure) }
        
        let dataPath = directory.appendingPathComponent(name)
        
        guard fileManager.fileExists(atPath: dataPath.path) else {
            return .failure(.fileNotExists)
        }
        
        do {
            return .success(try Data(contentsOf: dataPath))
        } catch {
            return .failure(.fileReadingFailure)
        }
    }
    func delete(at path: String, fileName name: String) async -> Result<Void, MHDataError> {
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
    func copy(at url: URL, to newPath: String, newFileName name: String) async -> Result<Void, MHDataError> {
        let originDataPath = url
        
        guard fileManager.fileExists(atPath: originDataPath.path) else {
            return .failure(.fileNotExists)
        }
        
        guard let newDirectory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: newPath)
        else { return .failure(.directorySettingFailure) }
        
        let newDataPath = newDirectory.appendingPathComponent(name)
        
        do {
            try fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: true)
            try fileManager.copyItem(at: originDataPath, to: newDataPath)
            return .success(())
        } catch {
            return .failure(.fileMovingFailure)
        }
    }
    func copy(at path: String, fileName name: String, to newPath: String) async -> Result<Void, MHDataError> {
        guard let originDirectory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: path)
        else { return .failure(.directorySettingFailure) }
        
        let originDataPath = originDirectory.appendingPathComponent(name)
        
        guard fileManager.fileExists(atPath: originDataPath.path) else {
            return .failure(.fileNotExists)
        }
        
        guard let newDirectory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: newPath)
        else { return .failure(.directorySettingFailure) }
        
        let newDataPath = newDirectory.appendingPathComponent(name)
        
        do {
            try fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: true)
            try fileManager.copyItem(at: originDataPath, to: newDataPath)
            return .success(())
        } catch {
            return .failure(.fileMovingFailure)
        }
    }
    func move(at path: String, fileName name: String, to newPath: String) async -> Result<Void, MHDataError> {
        guard let originDirectory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: path)
        else { return .failure(.directorySettingFailure) }
        
        let originDataPath = originDirectory.appendingPathComponent(name)
        
        guard fileManager.fileExists(atPath: originDataPath.path) else {
            return .failure(.fileNotExists)
        }
        
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
    func moveAll(in path: String, to newPath: String) async -> Result<Void, MHDataError> {
        guard let originDirectory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: path)
        else { return .failure(.directorySettingFailure) }
        
        guard fileManager.fileExists(atPath: originDirectory.path) else {
            return .failure(.fileNotExists)
        }
        
        guard let newDirectory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: newPath)
        else { return .failure(.directorySettingFailure) }
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: originDirectory.path)
            try fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: true)
            for file in files {
                let originDataPath = originDirectory.appendingPathComponent(file)
                let newDataPath = newDirectory.appendingPathComponent(file)
                try fileManager.moveItem(at: originDataPath, to: newDataPath)
            }
            return .success(())
        } catch {
            return .failure(.fileMovingFailure)
        }
    }
    func getURL(at path: String, fileName name: String) async -> Result<URL, MHDataError> {
        guard let originDirectory = fileManager.urls(
            for: directoryType,
            in: .userDomainMask
        ).first?.appending(path: path)
        else { return .failure(.directorySettingFailure) }
        
        let originDataPath = originDirectory.appendingPathComponent(name)
        
        return .success(originDataPath)
    }
}

