import MHDomain
import MHFoundation

struct StubFetchAllBookCoverUseCase: FetchAllBookCoverUseCase {
    func execute() async throws -> [BookCover] {
        return [
            BookCover(
                id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
                order: 0,
                title: "title1",
                imageURL: nil,
                color: .blue,
                category: "친구",
                favorite: false
            ),
            BookCover(
                id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
                order: 1,
                title: "title2",
                imageURL: nil,
                color: .blue,
                category: "가족",
                favorite: false
            ),
            BookCover(
                id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
                order: 2,
                title: "title3",
                imageURL: nil,
                color: .green,
                category: "전체",
                favorite: false
            )
        ]
    }
}

struct StubUpdateBookCoverUseCase: UpdateBookCoverUseCase {
    func execute(id: UUID, with bookCover: BookCover) async throws { }
}
