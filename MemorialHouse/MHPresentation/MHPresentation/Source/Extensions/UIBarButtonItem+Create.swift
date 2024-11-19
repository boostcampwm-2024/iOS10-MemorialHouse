import UIKit

extension UIBarButtonItem {
    /// UIBarButtonItem 편의 생성자
    /// - Parameters:
    ///   - title: 버튼 제목
    ///   - fontSize: 제목의 폰트 크기
    ///   - color: 제목 텍스트 색상
    ///   - action: 버튼 클릭 시 실행할 클로저
    convenience init(
        title: String,
        fontSize: CGFloat,
        color: UIColor,
        action: @escaping () -> Void
    ) {
        let uiAction = UIAction { _ in action() }
        self.init(title: title, primaryAction: uiAction)
        setTitleTextAttributes([
            .font: UIFont.ownglyphBerry(size: fontSize),
            .foregroundColor: color
        ], for: .normal)
    }
}
