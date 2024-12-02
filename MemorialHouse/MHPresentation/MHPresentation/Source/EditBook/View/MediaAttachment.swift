import UIKit
import AVKit
import MHDomain

protocol MediaAttachmentDataSource: AnyObject {
    func mediaAttachmentDragingImage(_ mediaAttachment: MediaAttachment, about view: UIView?) -> UIImage?
}

final class MediaAttachment: NSTextAttachment {
    // MARK: - Property
    private let view: (UIView & MediaAttachable)
    var cachedViewProvider: MediaAttachmentViewProvider?
    let mediaDescription: MediaDescription
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
    override func viewProvider(
        for parentView: UIView?,
        location: any NSTextLocation,
        textContainer: NSTextContainer?
    ) -> NSTextAttachmentViewProvider? {
        if let provider = cachedViewProvider {
            return provider
        }
        let provider = MediaAttachmentViewProvider(
            textAttachment: self,
            parentView: parentView,
            textLayoutManager: textContainer?.textLayoutManager,
            location: location
        )
        provider.tracksTextAttachmentViewBounds = true
        provider.view = view
        provider.type = mediaDescription.type
        cachedViewProvider = provider
        
        return provider
    }
    override func image(
        forBounds imageBounds: CGRect,
        textContainer: NSTextContainer?,
        characterIndex charIndex: Int
    ) -> UIImage? {
        cachedViewProvider = nil
        return dataSource?.mediaAttachmentDragingImage(self, about: view)
    }
    
    // MARK: - Method
    func configure(with data: Data) {
        view.configureSource(with: mediaDescription, data: data)
    }
    func configure(with url: URL) {
        view.configureSource(with: mediaDescription, url: url)
    }
}
