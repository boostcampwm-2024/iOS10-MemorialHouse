import UIKit
import MHFoundation
import MHDomain

// TODO: 위치 변경 고려해보기
extension BookType {
    var image: UIImage {
        switch self {
        case .blue: .blueBook
        case .beige: .beigeBook
        case .green: .greenBook
        case .orange: .orangeBook
        case .pink: .pinkBook
        @unknown default:
            fatalError("등록되지 않은 책 색상입니다.")
        }
    }
}
