import MHFoundation

public struct BookCoverDTO {
    let identifier: UUID
    let title: String
    let imageURL: String?
    let color: String
    let category: String?
    let favorite: Bool
}
