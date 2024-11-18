import Combine

final class CategoryViewModel {
    enum Input {
        case viewDidLoad
    }
    
    @Published private(set) var categories: [String] = []
    
    func action(_ input: CategoryViewModel.Input) {
        switch input {
        case .viewDidLoad:
            fetchCategories()
        }
    }
    
    private func fetchCategories() {
        categories = ["집주인들", "가족", "친구"]
    }
}
