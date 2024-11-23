import MHFoundation

public protocol BookCoverRepository {
    func fetchAllBookCovers() -> [BookCover]
    func fetchBookCover(with id: UUID) -> BookCover?
    func deleteBookCover(_ id: UUID)
    func create(bookCover: BookCover)
    func update(id: UUID, bookCover: BookCover)
}
