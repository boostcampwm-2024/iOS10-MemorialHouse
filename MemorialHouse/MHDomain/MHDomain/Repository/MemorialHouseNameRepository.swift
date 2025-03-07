import MHCore

public protocol MemorialHouseNameRepository: Sendable {
    func createMemorialHouseName(with name: String) async
    func fetchMemorialHouseName() async throws -> String
}
