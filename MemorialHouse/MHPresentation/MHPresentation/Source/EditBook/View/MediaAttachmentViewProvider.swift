import UIKit
import MHDomain

final class MediaAttachmentViewProvider: NSTextAttachmentViewProvider {
    // MARK: - Property
    var type: MediaType?
    private var height: CGFloat {
        type?.height ?? 100
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
