import Testing
@testable import MHDomain

struct MemorialHouseUseCaseTest {
    var sut: FetchMemorialHouseUseCase!
    
    @Test mutating func test유저하우스_엔티티모델_가져오기() async throws {
        // Arrange 준비 단계: 테스트 대상 시스템(SUT)와 의존성을 원하는 상태로 만들기
        let dummyMemorialHouse = MemorialHouse(
            name: "더미데이터",
            bookCovers: [
                BookCover(title: "책1", imageURL: "Temp", color: .beige, category: "가족"),
                BookCover(title: "책2", imageURL: "Temp", color: .beige, category: "친구")
            ]
        )
        let stubMemorialHouseRepository = StubMemorialHouseRepository(dummyData: dummyMemorialHouse)
        self.sut = DefaultFetchMemorialHouseNameUseCase(repository: stubMemorialHouseRepository)

        // Act 실행 단계: SUT 메소드를 호출하면서 의존성을 전달해서 결과를 저장하기
        let result = try await sut.execute()
        
        // Assert 검증 단계: 결과와 기대치를 비교해서 검증하기
        #expect(result.name == dummyMemorialHouse.name)
        #expect(result.bookCovers == dummyMemorialHouse.bookCovers)
    }
    
    @Test mutating func test세글자_이상인_경우_원본_문자열_그대로_반환() async throws {
        // Arrange 준비 단계: 테스트 대상 시스템(SUT)와 의존성을 원하는 상태로 만들기
        let dummyMemorialHouse = MemorialHouse(
            name: "Hello",
            bookCovers: []
        )
        let stubMemorialHouseRepository = StubMemorialHouseRepository(dummyData: dummyMemorialHouse)
        self.sut = DefaultFetchMemorialHouseNameUseCase(repository: stubMemorialHouseRepository)

        // Act 실행 단계: SUT 메소드를 호출하면서 의존성을 전달해서 결과를 저장하기
        let result = try await sut.execute()
        
        // Assert 검증 단계: 결과와 기대치를 비교해서 검증하기
        #expect(result.name == "Hello")
    }
    
    @Test mutating func test두글자_이하인_경우_글자_사이에_공백추가() async throws {
        // Arrange 준비 단계: 테스트 대상 시스템(SUT)와 의존성을 원하는 상태로 만들기
        let dummyMemorialHouse = MemorialHouse(
            name: "Hi",
            bookCovers: []
        )
        let stubMemorialHouseRepository = StubMemorialHouseRepository(dummyData: dummyMemorialHouse)
        self.sut = DefaultFetchMemorialHouseNameUseCase(repository: stubMemorialHouseRepository)

        // Act 실행 단계: SUT 메소드를 호출하면서 의존성을 전달해서 결과를 저장하기
        let result = try await sut.execute()
        
        // Assert 검증 단계: 결과와 기대치를 비교해서 검증하기
        #expect(result.name == "H i")
    }
}
