import Testing
@testable import MHDomain

struct UserHouseUseCaseTest {
    var sut: FetchUserHouseUseCase!
    
    @Test mutating func test유저하우스_엔티티모델_가져오기() async throws {
        // Arrange 준비 단계: 테스트 대상 시스템(SUT)와 의존성을 원하는 상태로 만들기
        let dummyUserHouse = UserHouse(
            name: "효준",
            categories: ["가족", "친구"],
            bookCovers: [
                BookCover(title: "책1", imageURL: "Temp", color: .beige, category: "가족"),
                BookCover(title: "책2", imageURL: "Temp", color: .beige, category: "친구")
            ]
        )
        let stubUserHouseRepository = StubUserHouseRepository(dummyData: dummyUserHouse)
        self.sut = DefaultFetchUserHouseUseCase(repository: stubUserHouseRepository)

        // Act 실행 단계: SUT 메소드를 호출하면서 의존성을 전달해서 결과를 저장하기
        let result = await sut.execute()
        
        // Assert 검증 단계: 결과와 기대치를 비교해서 검증하기
        #expect(result == dummyUserHouse)
    }
    
    @Test mutating func test세글자_이상인_경우_글자_사이에_공백추가() async throws {
        // Arrange 준비 단계: 테스트 대상 시스템(SUT)와 의존성을 원하는 상태로 만들기
        let dummyUserHouse = UserHouse(
            name: "Hello",
            categories: [],
            bookCovers: []
        )
        let stubUserHouseRepository = StubUserHouseRepository(dummyData: dummyUserHouse)
        self.sut = DefaultFetchUserHouseUseCase(repository: stubUserHouseRepository)

        // Act 실행 단계: SUT 메소드를 호출하면서 의존성을 전달해서 결과를 저장하기
        let result = await sut.execute()
        
        // Assert 검증 단계: 결과와 기대치를 비교해서 검증하기
        #expect(result.name == "H e l l o")
    }
    
    @Test mutating func test두글자_이하인_경우_원본_문자열_그대로_반환() async throws {
        // Arrange
        let dummyUserHouse = UserHouse(
            name: "Hi",
            categories: [],
            bookCovers: []
        )
        let stubUserHouseRepository = StubUserHouseRepository(dummyData: dummyUserHouse)
        self.sut = DefaultFetchUserHouseUseCase(repository: stubUserHouseRepository)

        // Act
        let result = await sut.execute()
        
        // Assert
        #expect(result.name == "Hi")
    }
}
