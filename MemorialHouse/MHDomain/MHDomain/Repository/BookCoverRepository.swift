import MHFoundation

// TODO: Result로 변경
public protocol BookCoverRepository {
    func fetchAllBookCovers() async -> [BookCover]
    func fetchBookCover(with id: UUID) async -> BookCover?
    func deleteBookCover(_ id: UUID) async
    func create(bookCover: BookCover) async
    func update(id: UUID, bookCover: BookCover) async
}
