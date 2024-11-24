import Combine
import Testing
@testable import MHPresentation
@testable import MHDomain

struct HomeViewModelTest {
    var sut: HomeViewModel!
    var cancellables = Set<AnyCancellable>()
    
    @MainActor
    @Test mutating func test시작할때_UserHouse_모델을_가져온다() async throws {
        // Arrange 준비 단계: 테스트 대상 시스템(SUT)와 의존성을 원하는 상태로 만들기
        let dummyUserHouse = UserHouse(
            name: "효준",
            categories: ["가족", "친구"],
            bookCovers: [
                BookCover(title: "책1", imageURL: "Temp", color: .beige, category: "가족"),
                BookCover(title: "책2", imageURL: "Temp", color: .beige, category: "친구")
            ]
        )
        let stubFetchUserHouseUseCase = StubFetchUserHouseUseCase(dummyUserHouse: dummyUserHouse)
        self.sut = HomeViewModel(fetchUserHouseUseCase: stubFetchUserHouseUseCase)
        
        let input = PassthroughSubject<HomeViewModel.Input, Never>()
        var receivedOutputs: [HomeViewModel.Output] = []
        
        sut.transform(input: input.eraseToAnyPublisher())
            .sink { output in
                receivedOutputs.append(output)
            }
            .store(in: &cancellables)
        
        // Act 실행 단계: SUT 메소드를 호출하면서 의존성을 전달해서 결과를 저장하기
        input.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Assert 검증 단계: 결과와 기대치를 비교해서 검증하기
        #expect(sut.houseName == "효준")
        #expect(sut.categories == ["전체", "즐겨찾기", "가족", "친구"])
        #expect(sut.bookCovers.count == 2)
    }
    
    @MainActor
    @Test mutating func test카테고리_선택시_해당_카테고리에_맞는_책들로_필터링한다() async throws {
        // Arrange 준비 단계: 테스트 대상 시스템(SUT)와 의존성을 원하는 상태로 만들기
        let dummyUserHouse = UserHouse(
            name: "효준",
            categories: ["가족", "친구"],
            bookCovers: [
                BookCover(title: "책1", imageURL: "Temp", color: .beige, category: "가족"),
                BookCover(title: "책2", imageURL: "Temp", color: .beige, category: "친구")
            ]
        )
        let stubFetchUserHouseUseCase = StubFetchUserHouseUseCase(dummyUserHouse: dummyUserHouse)
        self.sut = HomeViewModel(fetchUserHouseUseCase: stubFetchUserHouseUseCase)
        
        let input = PassthroughSubject<HomeViewModel.Input, Never>()
        var receivedOutputs: [HomeViewModel.Output] = []
        
        sut.transform(input: input.eraseToAnyPublisher())
            .sink { output in
                receivedOutputs.append(output)
            }
            .store(in: &cancellables)
        
        input.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Act 실행 단계: SUT 메소드를 호출하면서 의존성을 전달해서 결과를 저장하기
        input.send(.selectedCategory(index: 3)) // 전체, 즐겨찾기, 가족, 친구 중에서 친구 선택
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Assert 검증 단계: 결과와 기대치를 비교해서 검증하기
        #expect(sut.currentBookCovers.count == 1)
        #expect(sut.currentBookCovers.first?.title == "책2")
    }
    
    @MainActor
    @Test mutating func test유효하지_않은_인덱스를_선택하면_에러를_발생시킨다() async throws {
        // Arrange 준비 단계: 테스트 대상 시스템(SUT)와 의존성을 원하는 상태로 만들기
        let dummyUserHouse = UserHouse(
            name: "효준",
            categories: ["가족", "친구"],
            bookCovers: [
                BookCover(title: "책1", imageURL: "Temp", color: .beige, category: "가족"),
                BookCover(title: "책2", imageURL: "Temp", color: .beige, category: "친구")
            ]
        )
        let stubFetchUserHouseUseCase = StubFetchUserHouseUseCase(dummyUserHouse: dummyUserHouse)
        self.sut = HomeViewModel(fetchUserHouseUseCase: stubFetchUserHouseUseCase)
        
        let input = PassthroughSubject<HomeViewModel.Input, Never>()
        var receivedOutputs: [HomeViewModel.Output] = []
        
        sut.transform(input: input.eraseToAnyPublisher())
            .sink { output in
                receivedOutputs.append(output)
            }
            .store(in: &cancellables)
        
        input.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Act 실행 단계: SUT 메소드를 호출하면서 의존성을 전달해서 결과를 저장하기
        receivedOutputs.removeAll()
        input.send(.selectedCategory(index: 999))
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Assert 검증 단계: 결과와 기대치를 비교해서 검증하기
        #expect(receivedOutputs.isEmpty)
    }
}
