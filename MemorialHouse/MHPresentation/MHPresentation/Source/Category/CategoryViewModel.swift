import MHFoundation

final class CategoryViewModel {
    private(set) var categories: [String]
    private(set) var currentCategoryIndex: Int
    
    init(categories: [String], currentCategoryIndex: Int) {
        self.categories = categories
        self.currentCategoryIndex = currentCategoryIndex
    }
}
