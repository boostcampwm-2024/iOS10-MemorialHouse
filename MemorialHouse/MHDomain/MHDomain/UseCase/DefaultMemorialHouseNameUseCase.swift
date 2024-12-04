import MHCore

public struct DefaultCreateMemorialHouseNameUseCase: CreateMemorialHouseNameUseCase {
    private let repository: MemorialHouseNameRepository
    
    public init(repository: MemorialHouseNameRepository) {
        self.repository = repository
    }
    
    public func execute(with name: String) async throws {
        return try await repository.createMemorialHouseName(with: name).get()
    }
}

public struct DefaultFetchMemorialHouseNameUseCase: FetchMemorialHouseNameUseCase {
    private let repository: MemorialHouseNameRepository
    
    public init(repository: MemorialHouseNameRepository) {
        self.repository = repository
    }
    
    public func execute() async throws -> String {
        let fetchMemorialHouseResult = await repository.fetchMemorialHouseName()
        switch fetchMemorialHouseResult {
        case .success(let memorialHouseName):
            let transformedName = transformHouseName(with: memorialHouseName)
            MHLogger.info("저장된 기록소 이름: \(transformedName)")
            
            return transformedName
        case .failure(let failure):
            throw failure
        }
    }
    
    // TODO: 기록소가 아닌, 책 제목으로 변경
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
