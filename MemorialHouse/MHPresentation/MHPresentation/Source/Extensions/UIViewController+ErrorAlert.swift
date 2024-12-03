import UIKit

extension UIViewController {
    func showErrorAlert(with errorMessage: String) {
        let alertController = UIAlertController(
            title: "에러",
            message: errorMessage,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "확인", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
}
