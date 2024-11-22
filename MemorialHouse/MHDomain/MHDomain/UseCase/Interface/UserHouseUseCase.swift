public protocol FetchUserHouseUseCase: Sendable {
    func execute() async -> UserHouse
}
