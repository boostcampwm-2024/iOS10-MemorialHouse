import MHCore
public struct DefaultFetchMemorialHouseUseCase: FetchMemorialHouseUseCase {
    private let repository: MemorialHouseRepository
    
    public init(repository: MemorialHouseRepository) {
        self.repository = repository
    }
    
    public func execute() async throws -> MemorialHouse {
        let fetchMemorialHouseResult = await repository.fetchMemorialHouse()
        switch fetchMemorialHouseResult {
        case .success(let memorialHouse):
            let transformedName = transformHouseName(with: memorialHouse.name)
            MHLogger.info("Memorial house fetched: \(transformedName)")
            
            return MemorialHouse(
                name: transformedName,
                bookCovers: memorialHouse.bookCovers
            )
        case .failure(let failure):
            throw failure
        }
    }
    
    /// 집 이름이 2글자인 경우, 각 글자 사이에 공백을 추가하여 변환합니다.
    ///
    /// - Parameter name: 원본 이름 문자열.
    /// - Returns: 글자 사이에 공백이 추가된 문자열(두 글자인 경우).
    ///   한 글자, 혹은 세 글자 이상라면 원본 문자열 그대로 반환합니다.
    private func transformHouseName(with name: String) -> String {
        guard name.count == 2 else { return name }
        return name.map { String($0) }.joined(separator: " ")
    }
}
