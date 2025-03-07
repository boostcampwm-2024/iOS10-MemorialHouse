import Foundation
import MHCore

public protocol BookCategoryStorage: Sendable {
    func create(with category: BookCategoryDTO) throws
    func fetch() throws -> [BookCategoryDTO]
    func update(oldName: String, with category: BookCategoryDTO) throws
    func delete(with categoryName: String) throws
}
