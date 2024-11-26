public protocol FetchMemorialHouseUseCase: Sendable {
    func execute() async -> MemorialHouse
}
