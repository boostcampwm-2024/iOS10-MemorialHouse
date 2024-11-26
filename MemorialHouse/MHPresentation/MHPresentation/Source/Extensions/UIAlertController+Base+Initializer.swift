import UIKit

extension UIAlertController {
    /// UIAlertController의 기본 편의 생성자 (텍스트 필드 없음)
    /// - Parameters:
    ///   - title: Alert의 제목
    ///   - message: Alert의 메시지
    ///   - preferredStyle: Alert의 스타일 (기본값: .alert)
    ///   - confirmTitle: 확인 버튼의 제목 (기본값: "확인")
    ///   - cancelTitle: 취소 버튼의 제목 (기본값: "취소")
    ///   - confirmHandler: 확인 버튼 클릭 시 실행될 핸들러
    convenience init(
        title: String?,
        message: String? = nil,
        preferredStyle: UIAlertController.Style = .alert,
        confirmTitle: String = "확인",
        cancelTitle: String = "취소",
        confirmHandler: (() -> Void)? = nil
    ) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)
        
        // 확인 액션 추가
        let confirmAction = UIAlertAction(title: confirmTitle, style: .default) { _ in
            confirmHandler?()
        }
        self.addAction(confirmAction)
        
        // 취소 액션 추가
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        self.addAction(cancelAction)
    }
}
