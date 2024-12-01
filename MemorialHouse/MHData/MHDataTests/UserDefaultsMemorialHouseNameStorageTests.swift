import Testing
@testable import MHData
@testable import MHCore
@testable import MHFoundation

struct UserDefaultsMemorialHouseNameStorageTest {
    @MainActor
    @Test mutating func test저장소에_기록소_이름을_저장한다() async throws {
        // Arrange
        let suiteName = UUID().uuidString
        let userDefaults = UserDefaults(suiteName: suiteName)!
        let storage = UserDefaultsMemorialHouseNameStorage(userDefaults: userDefaults)
        let testName = "테스트 기록소"

        // Act
        let result = await storage.create(with: testName)

        // Assert
        switch result {
        case .success:
            // 비동기 작업 후 일정 시간 대기 (필요 시)
            let savedName = userDefaults.string(forKey: Constant.houseNameUserDefaultKey)
            #expect(savedName == testName)
        case .failure:
            throw MHDataError.noSuchEntity(key: suiteName)
        }

        userDefaults.removePersistentDomain(forName: suiteName)
    }

    @MainActor
    @Test mutating func test_fetch_저장소에서_기록소_이름을_불러온다() async throws {
        // Arrange
        let suiteName = UUID().uuidString
        let userDefaults = UserDefaults(suiteName: suiteName)!
        let storage = UserDefaultsMemorialHouseNameStorage(userDefaults: userDefaults)
        let testName = "테스트 기록소"
        userDefaults.set(testName, forKey: Constant.houseNameUserDefaultKey)

        // Act
        let result = await storage.fetch()

        // Assert
        switch result {
        case .success(let fetchedName):
            #expect(fetchedName == testName)
        case .failure:
            throw MHDataError.noSuchEntity(key: suiteName)
        }

        userDefaults.removePersistentDomain(forName: suiteName)
    }

    @MainActor
    @Test mutating func test_fetch_기록소_이름이_없을때_에러를_반환한다() async throws {
        // Arrange
        let suiteName = UUID().uuidString
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        let storage = UserDefaultsMemorialHouseNameStorage(userDefaults: userDefaults)

        // Act
        let result = await storage.fetch()

        // Assert
        switch result {
        case .success:
            throw MHDataError.noSuchEntity(key: suiteName)
        case .failure(let error):
            #expect(error == .noSuchEntity(key: Constant.houseNameUserDefaultKey))
        }

        userDefaults.removePersistentDomain(forName: suiteName)
    }
}
