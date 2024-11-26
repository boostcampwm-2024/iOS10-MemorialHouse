import Testing
@testable import MHCore
@testable import MHData
@testable import MHDomain
@testable import MHFoundation

struct CoreDataBookCoverStorageTests {
    // MARK: - Properties
    private let sut = CoreDataBookCoverStorage(coreDataStorage: MockCoreDataStorage())
    private static let bookCovers = [
        BookCoverDTO(
            identifier: UUID(),
            title: "test1",
            imageURL: nil,
            color: "pink",
            category: nil,
            favorite: true),
        BookCoverDTO(
            identifier: UUID(),
            title: "test2",
            imageURL: nil,
            color: "blue",
            category: nil,
            favorite: false),
        BookCoverDTO(
            identifier: UUID(),
            title: "test3",
            imageURL: nil,
            color: "beige",
            category: nil,
            favorite: true)
    ]
    
    init() async {
        for bookCover in CoreDataBookCoverStorageTests.bookCovers {
            _ = await sut.create(data: bookCover)
        }
    }
    
    @Test func test코어데이터에_새로운_BookCover_객체를_생성한다() async throws {
        // Arrange
        let newBookCover = BookCoverDTO(
            identifier: UUID(),
            title: "test4",
            imageURL: nil,
            color: "green",
            category: nil,
            favorite: true)
        
        // Act
        let result = await sut.create(data: newBookCover)
        let coreDataBookCovers = try await sut.fetch().get()
        
        // Assert
        switch result {
        case .success:
            #expect(coreDataBookCovers.contains(where: { $0.identifier == newBookCover.identifier }))
        case .failure(let error):
            #expect(false, "Create BookCover 실패: \(error.localizedDescription)")
        }
    }
    
    @Test func test코어데이터에_저장된_BookCover_객체들을_모두_불러온다() async {
        // Arrange
        // Act
        let result = await sut.fetch()
        
        // Assert
        switch result {
        case .success(let bookCoversResult):
            bookCoversResult.forEach { bookCoverResult in
                #expect(CoreDataBookCoverStorageTests.bookCovers.contains(where: {
                    bookCoverResult.identifier == $0.identifier
                }))
            }
        case .failure(let error):
            #expect(false, "Fetch BookCover 실패: \(error.localizedDescription)")
        }
    }
    
    @Test func test코어데이터에서_특정_UUID값을_가진_BookCover_데이터를_업데이트한다() async throws {
        // Arrange
        let oldBookCover = CoreDataBookCoverStorageTests.bookCovers[0]
        let newBookCover = BookCoverDTO(
            identifier: oldBookCover.identifier,
            title: "test4",
            imageURL: nil,
            color: "green",
            category: nil,
            favorite: true)
        
        // Act
        let result = await sut.update(with: oldBookCover.identifier, data: newBookCover)
        let coreDataBookCovers = try await sut.fetch().get()
        
        // Assert
        switch result {
        case .success:
            let newBookCoverResult = coreDataBookCovers.first(where: { $0.identifier == oldBookCover.identifier })
            #expect(newBookCoverResult?.title != oldBookCover.title)
        case .failure(let error):
            #expect(false, "Update BookCover 실패: \(error.localizedDescription)")
        }
    }
    
    @Test(arguments: [CoreDataBookCoverStorageTests.bookCovers[0].identifier,
                      CoreDataBookCoverStorageTests.bookCovers[1].identifier,
                      UUID()]
    ) func test코어데이터에서_특정_UUID값을_가진_BookCover_데이터를_삭제한다(_ id: UUID) async throws {
        // Arrange
        // Act
        let result = await sut.delete(with: id)
        let coreDataBookCovers = try await sut.fetch().get()
        
        // Assert
        switch result {
        case .success:
            #expect(!coreDataBookCovers.contains(where: { $0.identifier == id }))
        case .failure(let error):
            #expect(error == MHError.findEntityFailure && !coreDataBookCovers.contains(where: { $0.identifier == id }))
        }
    }
}
