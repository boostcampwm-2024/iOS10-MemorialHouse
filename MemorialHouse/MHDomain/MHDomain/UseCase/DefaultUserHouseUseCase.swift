public struct DefaultFetchUserHouseUseCase: FetchUserHouseUseCase {
    private let repository: UserHouseRepository
    
    public init(repository: UserHouseRepository) {
        self.repository = repository
    }
    
    public func execute() async -> UserHouse {
        return await repository.fetchUserHouse()
    }
}
