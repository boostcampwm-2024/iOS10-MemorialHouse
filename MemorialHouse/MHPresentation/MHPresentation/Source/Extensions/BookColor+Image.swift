import UIKit
import MHDomain

extension BookColor {
    var image: UIImage {
        switch self {
        case .blue: .blueBook
        case .beige: .beigeBook
        case .green: .greenBook
        case .orange: .orangeBook
        case .pink: .pinkBook
        default: .blueBook
        }
    }
}
