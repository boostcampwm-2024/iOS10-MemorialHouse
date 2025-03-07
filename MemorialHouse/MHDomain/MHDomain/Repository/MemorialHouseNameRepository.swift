import MHCore

public protocol MemorialHouseNameRepository: Sendable {
    func createMemorialHouseName(with name: String)
    func fetchMemorialHouseName() throws -> String
}
