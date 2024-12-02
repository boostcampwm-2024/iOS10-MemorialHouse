import Combine
import Testing
import MHFoundation
@testable import MHPresentation
@testable import MHDomain

struct HomeViewModelTest {
    private var sut: HomeViewModel!
    private var cancellables = Set<AnyCancellable>()
    private static let bookCovers = [
        BookCover(id: UUID(), order: 0, title: "title1", imageURL: nil, color: .blue, category: nil, favorite: false),
        BookCover(id: UUID(), order: 1, title: "title2", imageURL: nil, color: .blue, category: nil, favorite: false),
        BookCover(id: UUID(), order: 2, title: "title3", imageURL: nil, color: .blue, category: nil, favorite: false)
    ]

    @MainActor
    @Test mutating func test홈화면을_시작할때_MemorialHouse_이름과_책커버들을_가져온다() async throws {
        // Arrange
        let stubFetchMemorialHouseNameUseCase = StubFetchMemorialHouseNameUseCase(dummyMemorialHouseName: "효준")
        let stubFetchAllBookCoverUseCase = StubFetchAllBookCoverUseCase()
        let stubBookCovers = try await stubFetchAllBookCoverUseCase.execute()
        sut = HomeViewModel(
            fetchMemorialHouseUseCase: stubFetchMemorialHouseNameUseCase,
            fetchAllBookCoverUseCase: stubFetchAllBookCoverUseCase,
            updateBookCoverUseCase: StubUpdateBookCoverUseCase()
        )

        let input = PassthroughSubject<HomeViewModel.Input, Never>()
        var receivedOutput: [HomeViewModel.Output] = []

        sut.transform(input: input.eraseToAnyPublisher())
            .sink { output in
                receivedOutput.append(output)
            }
            .store(in: &cancellables)

        // Act
        receivedOutput.removeAll()
        input.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: 500_000_000)

        // Assert
        #expect(receivedOutput.count == 2)
        #expect(receivedOutput.contains(.fetchedMemorialHouseName))
        #expect(receivedOutput.contains(.fetchedAllBookCover))
        #expect(sut.houseName == "효준")
        #expect(sut.bookCovers == stubBookCovers)
    }

    @MainActor
    @Test mutating func test카테고리_선택시_해당_카테고리에_맞는_책들로_필터링한다() async throws {
        // Arrange
        sut = HomeViewModel(
            fetchMemorialHouseUseCase: StubFetchMemorialHouseNameUseCase(dummyMemorialHouseName: "효준"),
            fetchAllBookCoverUseCase: StubFetchAllBookCoverUseCase(),
            updateBookCoverUseCase: StubUpdateBookCoverUseCase()
        )
        let input = PassthroughSubject<HomeViewModel.Input, Never>()
        var receivedOutput: [HomeViewModel.Output] = []
        sut.transform(input: input.eraseToAnyPublisher())
            .sink { output in
                receivedOutput.append(output)
            }
            .store(in: &cancellables)
        
        // Act
        input.send(.viewDidLoad)
        try await Task.sleep(nanoseconds: 500_000_000)
        receivedOutput.removeAll()
        
        input.send(.selectedCategory(category: "친구"))
        try await Task.sleep(nanoseconds: 500_000_000)

        // Assert
        #expect(receivedOutput.count == 1)
        #expect(receivedOutput.contains(.filteredBooks))
        #expect(sut.currentBookCovers.count == 1)
        #expect(sut.currentBookCovers.first?.title == "title1")
    }
}
