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
        switch style {
        case .default: configureDefault()
        case .header: configureHeader()
        case .body: configureBody()
        }
    }
    
    func configureDefault() {
        self.font = UIFont.ownglyphBerry(size: 25)
        self.textColor = .title
        self.textAlignment = .center
    }
    
    func configureHeader() {
        self.font = UIFont.ownglyphBerry(size: 30)
        self.textColor = .title
        self.textAlignment = .center
    }
    
    func configureBody() {
        self.font = UIFont.ownglyphBerry(size: 17)
        self.textColor = .title
        self.textAlignment = .center
    }
}
