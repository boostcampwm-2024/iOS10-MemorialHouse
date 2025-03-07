import Foundation
import MHCore

public protocol BookCategoryStorage: Sendable {
    func create(with category: BookCategoryDTO) async throws
    func fetch() async throws -> [BookCategoryDTO]
    func update(oldName: String, with category: BookCategoryDTO) async throws
    func delete(with categoryName: String) async throws
}
