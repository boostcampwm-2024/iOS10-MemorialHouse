public protocol FetchMemorialHouseUseCase: Sendable {
    func execute() async throws -> MemorialHouse
}
