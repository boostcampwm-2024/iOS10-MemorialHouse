public struct DefaultFetchUserHouseUseCase: FetchUserHouseUseCase {    
    private let repository: UserHouseRepository
    
    public init(repository: UserHouseRepository) {
        self.repository = repository
    }
    
    public func execute() async -> UserHouse {
        let userHouse = await repository.fetchUserHouse()
        let transformedName = transformHouseName(with: userHouse.name)
        
        return UserHouse(
            name: transformedName,
            categories: userHouse.categories,
            bookCovers: userHouse.bookCovers
        )
    }
    
    /// 집 이름이 3글자 이상일 경우, 각 글자 사이에 공백을 추가하여 변환합니다.
    ///
    /// - Parameter name: 원본 이름 문자열.
    /// - Returns: 글자 사이에 공백이 추가된 문자열(3글자 이상인 경우).
    ///   2글자 이하라면 원본 문자열 그대로 반환합니다.
    private func transformHouseName(with name: String) -> String {
        guard name.count > 2 else { return name }
        return name.map { String($0) }.joined(separator: " ")
    }
}
