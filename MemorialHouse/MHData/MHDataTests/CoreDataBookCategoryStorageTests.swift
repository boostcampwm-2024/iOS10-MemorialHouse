import Testing
@testable import MHCore
@testable import MHData
@testable import MHDomain
@testable import MHFoundation

struct CoreDataBookCategoryStorageTests {
    // MARK: - Properties
    private let sut = CoreDataBookCategoryStorage(coreDataStorage: MockCoreDataStorage())
    private static let bookCategories = [
        BookCategoryDTO(order: 0, name: "전체"),
        BookCategoryDTO(order: 1, name: "즐겨찾기"),
        BookCategoryDTO(order: 2, name: "가족"),
        BookCategoryDTO(order: 3, name: "친구"),
    ]
    
    init() async {
        for bookCategory in CoreDataBookCategoryStorageTests.bookCategories {
            _ = await sut.create(with: bookCategory)
        }
    }
    
    @Test func test코어데이터에_새로운_BookCategory_객체를_생성한다() async throws {
        // Arrange
        let newBookCategory = BookCategoryDTO(order: 4, name: "스티브 임과 함께")
        
        // Act
        let result = await sut.create(with: newBookCategory)
        let coreDataBookCategories = try await sut.fetch().get()
        
        // Assert
        switch result {
        case .success:
            #expect(coreDataBookCategories.contains(where: { $0.name == newBookCategory.name }))
        case .failure(let error):
            #expect(false, "Create BookCategory 실패: \(error.localizedDescription)")
        }
    }
    
    @Test func test코어데이터에_저장된_BookCategory_객체들을_모두_불러온다() async {
        // Arrange
        // Act
        let result = await sut.fetch()
        
        // Assert
        switch result {
        case .success(let bookCategoriesResult):
            bookCategoriesResult.forEach { bookCategory in
                #expect(CoreDataBookCategoryStorageTests.bookCategories.contains(where: {
                    bookCategory.name == $0.name
                }))
            }
        case .failure(let error):
            #expect(false, "Fetch BookCategory 실패: \(error.localizedDescription)")
        }
    }
    
    @Test func test코어데이터에서_특정_이름을_가진_BookCategory_데이터를_업데이트한다() async throws {
        // Arrange
        let oldBookCategory = CoreDataBookCategoryStorageTests.bookCategories[0]
        let newBookCategory = BookCategoryDTO(order: 0, name: "전체(All)")
        
        // Act
        let result = await sut.update(oldName: oldBookCategory.name, with: newBookCategory)
        let coreDataBookCategories = try await sut.fetch().get()
        
        // Assert
        switch result {
        case .success:
            let newBookCategories = coreDataBookCategories.first(where: { $0.name == oldBookCategory.name })
            #expect(newBookCategories?.name != oldBookCategory.name)
        case .failure(let error):
            #expect(false, "Update BookCategory 실패: \(error.localizedDescription)")
        }
    }
    
    @Test(
        arguments: [
            CoreDataBookCategoryStorageTests.bookCategories[0].name,
            CoreDataBookCategoryStorageTests.bookCategories[1].name,
            "친구"
        ]
    ) func test코어데이터에서_특정_이름을_가진_BookCategory_데이터를_삭제한다(_ categoryName: String) async throws {
        // Arrange
        // Act
        let result = await sut.delete(with: categoryName)
        let coreDataBookCategories = try await sut.fetch().get()
        
        // Assert
        switch result {
        case .success:
            #expect(!coreDataBookCategories.contains(where: { $0.name == categoryName }))
        case .failure(let error):
            #expect(error == MHDataError.findEntityFailure && !coreDataBookCategories.contains(where: { $0.name == categoryName }))
        }
    }
}

