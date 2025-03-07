import Foundation
import MHCore

// TODO: 기록소 이름 변경
public protocol MemorialHouseNameStorage: Sendable {
    func create(with memorialHouseName: String)
    func fetch() throws -> String
}
