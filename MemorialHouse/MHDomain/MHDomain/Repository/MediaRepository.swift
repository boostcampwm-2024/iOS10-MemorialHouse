import MHFoundation

public protocol MediaRepository {
    func create(at path: String, fileName name: String, data: Data) async
    func read(at path: String, fileName name: String) async -> Data?
    func delete(at path: String, fileName name: String) async
    func move(at path: String, fileName name: String, to newPath: String) async
}
