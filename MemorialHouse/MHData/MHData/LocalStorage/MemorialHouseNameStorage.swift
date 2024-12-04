import MHFoundation
import MHCore

// TODO: 기록소 이름 변경
public protocol MemorialHouseNameStorage: Sendable {
    func create(with memorialHouseName: String) async -> Result<Void, MHDataError>
    func fetch() async -> Result<String, MHDataError>
}
