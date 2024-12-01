import MHCore
import MHFoundation

public struct UserDefaultsMemorialHouseNameStorage: MemorialHouseNameStorage {
    private nonisolated(unsafe) let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    public func create(with memorialHouseName: String) async -> Result<Void, MHDataError> {
        userDefaults.set(memorialHouseName, forKey: Constant.houseNameUserDefaultKey)
        
        if userDefaults.string(forKey: Constant.houseNameUserDefaultKey) == memorialHouseName {
            return .success(())
        } else {
            return .failure(.setUserDefaultFailure)
        }
    }
    
    public func fetch() async -> Result<String, MHDataError> {
        guard let memorialHouseName = userDefaults.string(forKey: Constant.houseNameUserDefaultKey) else {
            MHLogger.error("MemorialHouseName을 찾을 수 없습니다: \(Constant.houseNameUserDefaultKey)")
            return .failure(.noSuchEntity(key: Constant.houseNameUserDefaultKey))
        }
        return .success(memorialHouseName)
    }
}
