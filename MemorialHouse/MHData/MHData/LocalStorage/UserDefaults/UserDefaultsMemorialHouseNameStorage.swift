import MHCore
import MHFoundation

public struct UserDefaultsMemorialHouseNameStorage: MemorialHouseNameStorage {
    public init() { }
    
    public func create(with memorialHouseName: String) async -> Result<Void, MHDataError> {
        UserDefaults.standard.set(
            memorialHouseName,
            forKey: Constant.houseNameUserDefaultKey
        )
        return .success(())
    }
    
    public func fetch() async -> Result<String, MHDataError> {
        guard let memorialHouseName = UserDefaults.standard.string(forKey: Constant.houseNameUserDefaultKey) else {
            return .failure(.noSuchEntity(key: Constant.houseNameUserDefaultKey))
        }
        return .success(memorialHouseName)
    }
}
