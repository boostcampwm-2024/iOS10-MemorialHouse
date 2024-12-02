import UIKit
import MHDomain

final class MediaAttachmentViewProvider: NSTextAttachmentViewProvider {
    // MARK: - Property
    var type: MediaType?
    private var height: CGFloat {
        switch type { // TODO: - 조정 필요
        case .image:
            300
        case .video:
            200
        case .audio:
            100
        case nil:
            10
        default:
            100
        }
    }
    
    override func attachmentBounds(
        for attributes: [NSAttributedString.Key: Any],
        location: NSTextLocation,
        textContainer: NSTextContainer?,
        proposedLineFragment: CGRect,
        position: CGPoint
    ) -> CGRect {
        return CGRect(x: 0, y: 0, width: proposedLineFragment.width, height: height)
    }
}
