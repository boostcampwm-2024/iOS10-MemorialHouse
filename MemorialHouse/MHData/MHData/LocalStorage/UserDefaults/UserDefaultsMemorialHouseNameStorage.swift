import MHCore
import Foundation

public struct UserDefaultsMemorialHouseNameStorage: MemorialHouseNameStorage {
    private nonisolated(unsafe) let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    public func create(with memorialHouseName: String) async {
        userDefaults.set(memorialHouseName, forKey: Constant.houseNameUserDefaultKey)
    }
    
    public func fetch() async throws -> String {
        guard let memorialHouseName = userDefaults.string(forKey: Constant.houseNameUserDefaultKey) else {
            MHLogger.error("MemorialHouseName을 찾을 수 없습니다: \(Constant.houseNameUserDefaultKey)")
            throw MHDataError.noSuchEntity(key: Constant.houseNameUserDefaultKey)
        }
        return memorialHouseName
    }
}
