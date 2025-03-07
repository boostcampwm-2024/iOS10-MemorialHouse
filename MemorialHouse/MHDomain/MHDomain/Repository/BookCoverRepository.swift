import Foundation
import MHCore

public protocol BookCoverRepository: Sendable {
    func createBookCover(with bookCover: BookCover) async throws
    func fetchAllBookCovers() async throws -> [BookCover]
    func fetchBookCover(with id: UUID) async throws -> BookCover?
    func updateBookCover(id: UUID, with bookCover: BookCover) async throws
    func deleteBookCover(id: UUID) async throws
}
