public protocol CreateMemorialHouseNameUseCase: Sendable {
    func execute(with name: String) async
}

public protocol FetchMemorialHouseNameUseCase: Sendable {
    func execute() async throws -> String
}
