import UIKit

public extension UILabel {
    enum Style {
        case `default`
        case header
        case body1
        case body2
    }
    
    convenience init(style: Style) {
        self.init(frame: .zero)
        self.textColor = .mhTitle
        self.textAlignment = .center
        switch style {
        case .default:
            self.font = UIFont.ownglyphBerry(size: 25)
        case .header:
            self.font = UIFont.ownglyphBerry(size: 30)
        case .body1:
            self.font = UIFont.ownglyphBerry(size: 17)
        case .body2:
            self.font = UIFont.ownglyphBerry(size: 12)
        }
    }
}
