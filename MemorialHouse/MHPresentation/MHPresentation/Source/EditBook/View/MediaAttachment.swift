import UIKit
import AVKit

protocol MediaAttachmentDataSource: AnyObject {
    func mediaAttachmentDragingImage(_ mediaAttachment: MediaAttachment, about view: UIView?) -> UIImage?
}

final class MediaAttachment: NSTextAttachment {
    var view: (UIView & MediaAttachable)?
    var sourcePath: URL? {
        get {
            view?.sourcePath
        }
        set {
            view?.sourcePath = newValue
        }
    }
    weak var dataSource: MediaAttachmentDataSource?
    
    override func viewProvider(for parentView: UIView?, location: any NSTextLocation, textContainer: NSTextContainer?) -> NSTextAttachmentViewProvider? {
        let provider = MediaAttachmentViewProvider(
            textAttachment: self,
            parentView: parentView,
            textLayoutManager: textContainer?.textLayoutManager,
            location: location
        )
        provider.tracksTextAttachmentViewBounds = true
        provider.view = view
        return provider
    }
    override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        return dataSource?.mediaAttachmentDragingImage(self, about: view)
    }
}

class MediaAttachmentViewProvider: NSTextAttachmentViewProvider {
    override func attachmentBounds(
        for attributes: [NSAttributedString.Key: Any],
        location: NSTextLocation,
        textContainer: NSTextContainer?,
        proposedLineFragment: CGRect,
        position: CGPoint
    ) -> CGRect {
        return CGRect(x: 0, y: 0, width: proposedLineFragment.width, height: 300)
    }
}

protocol MediaAttachable {
    var sourcePath: URL? { get set }
}
