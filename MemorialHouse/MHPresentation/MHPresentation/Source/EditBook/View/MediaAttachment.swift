import UIKit
import AVKit
import MHDomain

protocol MediaAttachmentDataSource: AnyObject {
    func mediaAttachmentDragingImage(_ mediaAttachment: MediaAttachment, about view: UIView?) -> UIImage?
}

final class MediaAttachment: NSTextAttachment {
    // MARK: - Property
    private let view: (UIView & MediaAttachable)
    var mediaDescription: MediaDescription {
        didSet {
            view.configureSource(with: mediaDescription)
        }
    }
    weak var dataSource: MediaAttachmentDataSource?
    
    // MARK: - Initializer
    init(view: (UIView & MediaAttachable), description: MediaDescription) {
        self.view = view
        self.mediaDescription = description
        super.init(data: nil, ofType: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - ViewConfigures
    override func viewProvider(for parentView: UIView?, location: any NSTextLocation, textContainer: NSTextContainer?) -> NSTextAttachmentViewProvider? {
        let provider = MediaAttachmentViewProvider(
            textAttachment: self,
            parentView: parentView,
            textLayoutManager: textContainer?.textLayoutManager,
            location: location
        )
        provider.tracksTextAttachmentViewBounds = true
        provider.view = view
        provider.type = mediaDescription.type
        return provider
    }
    override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        return dataSource?.mediaAttachmentDragingImage(self, about: view)
    }
    
    // MARK: - Method
    func setup() {
        view.configureSource(with: mediaDescription)
    }
}

class MediaAttachmentViewProvider: NSTextAttachmentViewProvider {
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

// MARK: - MediaAttachable
protocol MediaAttachable {
    func configureSource(with description: MediaDescription)
}
