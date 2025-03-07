import Foundation
import MHCore

public protocol MemorialHouseNameStorage: Sendable {
    func create(with memorialHouseName: String) async
    func fetch() async throws -> String
}
