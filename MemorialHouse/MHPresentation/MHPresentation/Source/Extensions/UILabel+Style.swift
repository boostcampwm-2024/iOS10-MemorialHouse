import UIKit

enum LabelStyle {
    case `default`
    case header
    case body
}

extension UILabel {
    convenience init(style: LabelStyle) {
        self.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textColor = .title
        self.textAlignment = .center
        switch style {
        case .default:
            self.font = UIFont.ownglyphBerry(size: 25)
        case .header:
            self.font = UIFont.ownglyphBerry(size: 30)
        case .body:
            self.font = UIFont.ownglyphBerry(size: 17)
        }
    }
}
