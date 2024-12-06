import UIKit

extension UIViewController {
    @objc
    func keyboardWillShow(_ sender: Notification) {
        self.view.frame.origin.y = -120
    }
    
    @objc
    func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0
    }
}
