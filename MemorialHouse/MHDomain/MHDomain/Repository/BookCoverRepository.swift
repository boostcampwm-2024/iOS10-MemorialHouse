import MHFoundation

// TODO: Result로 변경
public protocol BookCoverRepository {
    func create(with bookCover: BookCover) async
    func fetchAllBookCovers() async -> [BookCover]
    func fetchBookCover(with id: UUID) async -> BookCover?
    func update(id: UUID, with bookCover: BookCover) async
    func deleteBookCover(_ id: UUID) async
}
