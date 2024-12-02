import MHCore

public protocol MemorialHouseNameRepository: Sendable {
    func createMemorialHouseName(with name: String) async -> Result<Void, MHDataError>
    func fetchMemorialHouseName() async -> Result<String, MHDataError>
}
