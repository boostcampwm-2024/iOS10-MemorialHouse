import Testing
@testable import MHDomain

struct MemorialHouseUseCaseTest {
    var sut: FetchMemorialHouseNameUseCase!
    
    @Test mutating func test기록소_이름_가져오기() async throws {
        // Arrange 준비 단계: 테스트 대상 시스템(SUT)와 의존성을 원하는 상태로 만들기
        let dummyMemorialHouseName = "집주인들"
        let stubMemorialHouseNameRepository = StubMemorialHouseRepository(
            dummyMemorialHouseName: dummyMemorialHouseName
        )
        self.sut = DefaultFetchMemorialHouseNameUseCase(repository: stubMemorialHouseNameRepository)

        // Act 실행 단계: SUT 메소드를 호출하면서 의존성을 전달해서 결과를 저장하기
        let result = try await sut.execute()
        
        // Assert 검증 단계: 결과와 기대치를 비교해서 검증하기
        #expect(result == dummyMemorialHouseName)
    }
    
    // TODO: 기록소 이름이 아닌, 책 이름으로 변경
    @Test mutating func test세글자_이상인_경우_원본_문자열_그대로_반환() async throws {
        // Arrange 준비 단계: 테스트 대상 시스템(SUT)와 의존성을 원하는 상태로 만들기
        let dummyMemorialHouseName = "집주인들"
        let stubMemorialHouseNameRepository = StubMemorialHouseRepository(
            dummyMemorialHouseName: dummyMemorialHouseName
        )
        self.sut = DefaultFetchMemorialHouseNameUseCase(repository: stubMemorialHouseNameRepository)

        // Act 실행 단계: SUT 메소드를 호출하면서 의존성을 전달해서 결과를 저장하기
        let result = try await sut.execute()
        
        // Assert 검증 단계: 결과와 기대치를 비교해서 검증하기
        #expect(result == dummyMemorialHouseName)
    }
    
    @Test mutating func test두글자_이하인_경우_글자_사이에_공백추가() async throws {
        // Arrange 준비 단계: 테스트 대상 시스템(SUT)와 의존성을 원하는 상태로 만들기
        let dummyMemorialHouseName = "집주인들"
        let stubMemorialHouseNameRepository = StubMemorialHouseRepository(
            dummyMemorialHouseName: dummyMemorialHouseName
        )
        self.sut = DefaultFetchMemorialHouseNameUseCase(repository: stubMemorialHouseNameRepository)

        // Act 실행 단계: SUT 메소드를 호출하면서 의존성을 전달해서 결과를 저장하기
        let result = try await sut.execute()
        
        // Assert 검증 단계: 결과와 기대치를 비교해서 검증하기
        #expect(result == dummyMemorialHouseName)
    }
}
