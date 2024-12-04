import UIKit

enum AlertType: CustomStringConvertible {
    case camera
    case image
    case audio
    
    var description: String {
        switch self {
        case .camera:
            "카메라"
        case .image:
            "사진"
        case .audio:
            "마이크"
        }
    }
}

extension UIViewController {
    func showRedirectSettingAlert(with content: AlertType) {
        let alertController = UIAlertController(
            title: "\(content.description) 권한이 필요합니다.",
            message: "\(content.description) 권한을 허용해야만\n해당 기능을 사용하실 수 있습니다.",
            confirmTitle: "설정",
            cancelTitle: "취소",
            confirmHandler: { _ in
                if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSetting)
                }
            },
            cancelHandler: { [weak self] in
                switch content {
                case .image, .camera:
                    self?.navigationController?.popViewController(animated: true)
                case .audio:
                    self?.dismiss(animated: true)
                }
            }
        )
        
        self.present(alertController, animated: true, completion: nil)
    }
}
