import MHFoundation
import MHDomain

public struct BookCategoryDTO {
    let order: Int
    let name: String
    
    public init(
        order: Int,
        name: String
    ) {
        self.order = order
        self.name = name
    }
    
    func convertToBookCategory() -> BookCategory {
        BookCategory(
            order: order,
            name: name
        )
    }
}
