import UIKit

extension UIBarButtonItem {
    /// UIBarButtonItem 편의 생성자
    /// - Parameters:
    ///   - title: 버튼 제목
    ///   - normal: 기본 상태의 속성 (Optional, 기본값 제공 가능)
    ///   - selected: 선택 상태의 속성 (Optional, 기본값 제공 가능)
    ///   - action: 버튼 클릭 시 실행할 클로저
    convenience init(
        title: String,
        normal: [NSAttributedString.Key: Any]? = nil,
        selected: [NSAttributedString.Key: Any]? = nil,
        action: @escaping () -> Void
    ) {
        let uiAction = UIAction { _ in action() }
        self.init(title: title, primaryAction: uiAction)
        
        if let normalAttributes = normal {
            setTitleTextAttributes(normalAttributes, for: .normal)
        }
        
        if let selectedAttributes = selected {
            setTitleTextAttributes(selectedAttributes, for: .selected)
        }
    }
}
