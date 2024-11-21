import UIKit

public extension UILabel {
    enum Style {
        case header1
        case header2
        case header3
        case body1
        case body2
        case body3
    }
    
    convenience init(style: Style) {
        self.init(frame: .zero)
        self.textColor = .mhTitle
        self.textAlignment = .center
        switch style {
        case .header1:
            self.font = UIFont.ownglyphBerry(size: 30)
        case .header2:
            self.font = UIFont.ownglyphBerry(size: 25)
        case .header3:
            self.font = UIFont.ownglyphBerry(size: 22)
        case .body1:
            self.font = UIFont.ownglyphBerry(size: 20)
        case .body2:
            self.font = UIFont.ownglyphBerry(size: 17)
        case .body3:
            self.font = UIFont.ownglyphBerry(size: 12)
        }
    }
}
