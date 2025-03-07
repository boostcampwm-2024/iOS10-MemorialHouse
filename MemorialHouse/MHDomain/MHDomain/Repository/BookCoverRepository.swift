import Foundation
import MHCore

public protocol BookCoverRepository: Sendable {
    func createBookCover(with bookCover: BookCover) throws
    func fetchAllBookCovers() throws -> [BookCover]
    func fetchBookCover(with id: UUID) throws -> BookCover?
    func updateBookCover(id: UUID, with bookCover: BookCover) throws
    func deleteBookCover(id: UUID) throws
}
