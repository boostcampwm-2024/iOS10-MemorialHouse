public protocol UserHouseRepository: Sendable {
    func fetchUserHouse() async -> UserHouse
}
