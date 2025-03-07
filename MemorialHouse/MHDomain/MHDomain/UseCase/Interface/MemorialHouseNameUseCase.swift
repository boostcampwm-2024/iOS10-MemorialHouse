public protocol CreateMemorialHouseNameUseCase: Sendable {
    func execute(with name: String)
}

public protocol FetchMemorialHouseNameUseCase: Sendable {
    func execute() throws -> String
}
