import UIKit

extension UIAlertController {
    /// UIAlertController의 편의 생성자
    /// - Parameters:
    ///   - title: Alert의 제목 (기본값 없음)
    ///   - message: Alert의 메시지 (기본값: nil)
    ///   - preferredStyle: Alert의 스타일 (기본값: .alert)
    ///   - textFieldConfiguration: 텍스트 필드를 구성하기 위한 클로저 (기본값: nil, 텍스트 필드가 없는 경우 생략 가능)
    ///   - confirmTitle: 확인 버튼의 제목 (기본값: "확인")
    ///   - cancelTitle: 취소 버튼의 제목 (기본값: "취소")
    ///   - confirmHandler: 확인 버튼 클릭 시 실행될 핸들러, 텍스트 필드 입력값(String?)을 매개변수로 전달 (기본값: nil)
    convenience init(
        title: String?,
        message: String? = nil,
        preferredStyle: UIAlertController.Style = .alert,
        textFieldConfiguration: ((UITextField) -> Void)? = nil,
        confirmTitle: String = "확인",
        cancelTitle: String = "취소",
        confirmHandler: ((String?) -> Void)? = nil
    ) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)
        
        // 텍스트 필드 추가 (필요한 경우)
        if let textFieldConfiguration = textFieldConfiguration {
            self.addTextField(configurationHandler: textFieldConfiguration)
        }
        
        // 확인 액션 추가
        let confirmAction = UIAlertAction(title: confirmTitle, style: .default) { _ in
            let text = self.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            confirmHandler?(textFieldConfiguration != nil ? text : nil)
        }
        self.addAction(confirmAction)
        
        // 취소 액션 추가
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        self.addAction(cancelAction)
    }
}
