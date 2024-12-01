public protocol CreateMemorialHouseNameUseCase: Sendable {
    func execute(with name: String) async throws
}

public protocol FetchMemorialHouseNameUseCase: Sendable {
    func execute() async throws -> String
}
