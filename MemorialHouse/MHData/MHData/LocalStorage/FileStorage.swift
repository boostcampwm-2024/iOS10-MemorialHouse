import MHFoundation
import MHCore

protocol FileStorage {
    func create(at path: String, fileName name: String, data: Data) async -> Result<Void, MHError>
    func read(at path: String, fileName name: String) async -> Result<Data, MHError>
    func delete(at path: String, fileName name: String) async -> Result<Void, MHError>
    func move(at path: String, fileName name: String, to newPath: String) async -> Result<Void, MHError>
}
