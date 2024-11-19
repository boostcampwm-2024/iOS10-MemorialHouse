import Combine
import MHFoundation

final class CategoryViewModel: ViewModelType {
    enum Input {
        case viewDidLoad
    }
    
    enum Output {
        case fetchedCategories
    }
    
    private(set) var dummyData: [String] = []
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                self?.fetchCategories()
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    func calculateSheetHeight() -> CGFloat {
        let cellHeight = CategoryTableViewCell.height
        let itemCount = CGFloat(dummyData.count)
        return (cellHeight * itemCount) + Constant.navigationBarHeight
    }
    
    private func fetchCategories() {
        dummyData = ["집주인들", "가족", "친구", "동료", "기타"]
        output.send(.fetchedCategories)
    }
}
