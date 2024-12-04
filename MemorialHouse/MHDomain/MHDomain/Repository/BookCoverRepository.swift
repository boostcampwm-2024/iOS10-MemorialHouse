import MHFoundation
import MHCore

public protocol BookCoverRepository: Sendable {
    func createBookCover(with bookCover: BookCover) async -> Result<Void, MHDataError>
    func fetchAllBookCovers() async -> Result<[BookCover], MHDataError>
    func fetchBookCover(with id: UUID) async -> Result<BookCover?, MHDataError>
    func updateBookCover(id: UUID, with bookCover: BookCover) async -> Result<Void, MHDataError>
    func deleteBookCover(id: UUID) async -> Result<Void, MHDataError>
}
