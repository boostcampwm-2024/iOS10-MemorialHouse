import Testing
@testable import MHCore
@testable import MHData
@testable import MHDomain
@testable import MHFoundation

struct CoreDataBookStorageTests {
    // MARK: - Properties
    private let sut = CoreDataBookStorage(coreDataStorage: MockCoreDataStorage())
    private static let books = [
        BookDTO(
            id: UUID(),
            pages: [
                PageDTO(
                    id: UUID(),
                    metadata: [
                        0: MediaDescriptionDTO(id: UUID(), type: "image", attributes: nil)
                    ],
                    text: "first page"
                ),
                PageDTO(
                    id: UUID(),
                    metadata: [
                        0: MediaDescriptionDTO(id: UUID(), type: "video", attributes: nil)
                    ],
                    text: "second page"
                ),
                PageDTO(
                    id: UUID(),
                    metadata: [
                        0: MediaDescriptionDTO(id: UUID(), type: "audio", attributes: nil)
                    ],
                    text: "third page"
                )
            ]
        ),
        BookDTO(
            id: UUID(),
            pages: [
                PageDTO(
                    id: UUID(),
                    metadata: [
                        0: MediaDescriptionDTO(id: UUID(), type: "image", attributes: nil)
                    ],
                    text: "first page"
                ),
                PageDTO(
                    id: UUID(),
                    metadata: [
                        0: MediaDescriptionDTO(id: UUID(), type: "video", attributes: nil)
                    ],
                    text: "second page"
                ),
                PageDTO(
                    id: UUID(),
                    metadata: [
                        0: MediaDescriptionDTO(id: UUID(), type: "audio", attributes: nil)
                    ],
                    text: "third page"
                )
            ]
        )
    ]
    
    init() async {
        _ = await sut.create(data: CoreDataBookStorageTests.books[0])
        _ = await sut.create(data: CoreDataBookStorageTests.books[1])
    }
    
    @Test func test코어데이터에_새로운_Book_객체를_생성한다() async throws {
        // Arrange
        let newBook = BookDTO(
            id: UUID(),
            pages: [
                PageDTO(
                    id: UUID(),
                    metadata: [
                        0: MediaDescriptionDTO(id: UUID(), type: "image", attributes: nil)
                    ],
                    text: "first page"
                ),
                PageDTO(
                    id: UUID(),
                    metadata: [
                        0: MediaDescriptionDTO(id: UUID(), type: "video", attributes: nil)
                    ],
                    text: "second page"
                ),
                PageDTO(
                    id: UUID(),
                    metadata: [
                        0: MediaDescriptionDTO(id: UUID(), type: "audio", attributes: nil)
                    ],
                    text: "third page"
                )
            ]
        )
        
        // Act
        let result = await sut.create(data: newBook)
        let coreDataBook = try await sut.fetch(with: newBook.id).get()
        
        // Assert
        switch result {
        case .success:
            #expect(coreDataBook.id == newBook.id)
        case .failure(let error):
            #expect(false, "Create Book 실패: \(error.description)")
        }
    }
    
    @Test func test코어데이터에_저장된_Book_객체를_불러온다() async {
        // Arrange
        // Act
        let result = await sut.fetch(with: CoreDataBookStorageTests.books[0].id)
        
        // Assert
        switch result {
        case .success(let bookResult):
            #expect(CoreDataBookStorageTests.books.contains(where: { $0.id == bookResult.id }))
        case .failure(let error):
            #expect(false, "Fetch Book 실패: \(error.description)")
        }
    }
    
    @Test func test코어데이터에서_특정_UUID값을_가진_Book_데이터를_업데이트한다() async throws {
        // Arrange
        let oldBook = CoreDataBookStorageTests.books[0]
        let newBook = BookDTO(
            id: oldBook.id,
            pages: [
                PageDTO(
                    id: oldBook.pages[0].id,
                    metadata: [
                        0: MediaDescriptionDTO(id: UUID(), type: "image", attributes: nil)
                    ],
                    text: "first page"
                ),
                PageDTO(
                    id: UUID(),
                    metadata: [
                        0: MediaDescriptionDTO(id: UUID(), type: "image", attributes: nil),
                        2: MediaDescriptionDTO(id: UUID(), type: "image", attributes: nil)
                    ],
                    text: "second page"
                ),
                PageDTO(
                    id: UUID(),
                    metadata: [
                        0: MediaDescriptionDTO(id: UUID(), type: "audio", attributes: nil)
                    ],
                    text: "third page"
                ),
                PageDTO(
                    id: UUID(),
                    metadata: [
                        0: MediaDescriptionDTO(id: UUID(), type: "video", attributes: nil)
                    ],
                    text: "fourth page"
                )
            ]
        )
        
        // Act
        let result = await sut.update(with: oldBook.id, data: newBook)
        let coreDataBook = try await sut.fetch(with: oldBook.id).get()
        
        // Assert
        switch result {
        case .success:
            let newBookResult = coreDataBook
            #expect(newBookResult.pages.count != oldBook.pages.count)
        case .failure(let error):
            #expect(false, "Update Book 실패: \(error.description)")
        }
    }
    
    @Test(arguments: [CoreDataBookStorageTests.books[0].id,
                      CoreDataBookStorageTests.books[1].id,
                      UUID()]
    ) func test코어데이터에서_특정_UUID값을_가진_BookCover_데이터를_삭제한다(_ id: UUID) async {
        // Arrange
        // Act
        let result = await sut.delete(with: id)
        let coreDataBook = await sut.fetch(with: id)
        
        // Assert
        switch result {
        case .success: // 삭제가 되면 성공한 거임
            #expect(true)
        case .failure(let error): // 삭제가 실패했을 때 오류를 발생해야 함
            #expect(error == MHDataError.findEntityFailure)
        }
        
        switch coreDataBook {
        case .success: // 조회가 되면 실패한 거임
            #expect(false, "Delete Book 실패: \(MHDataError.fetchEntityFaliure.description)")
        case .failure(let error): // 조회가 실패하면 성공한 거임
            #expect(error == MHDataError.findEntityFailure)
        }
    }
}
