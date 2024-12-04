import MHFoundation
import MHDomain
import UIKit

final class MHPolaroidPhotoView: UIView {
    // MARK: - UI Components
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .ownglyphBerry(size: 12)
        label.textColor = .mhTitle
        
        return label
    }()
    
    private let creationDateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .right
        label.font = .ownglyphBerry(size: 12)
        label.textColor = .mhTitle
        
        return label
    }()
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        configureAddSubviews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        
        setup()
        configureAddSubviews()
        configureConstraints()
    }
    
    // MARK: - Setup & Configure
    private func setup() {
        backgroundColor = .white
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }
    
    private func configureAddSubviews() {
        addSubview(photoImageView)
        addSubview(captionLabel)
        addSubview(creationDateLabel)
    }
    
    private func configureConstraints() {
        photoImageView.setAnchor(top: topAnchor, constantTop: 25,
                                 leading: leadingAnchor, constantLeading: 17,
                                 trailing: trailingAnchor, constantTrailing: 17)
        NSLayoutConstraint.activate([
            photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor, multiplier: 0.75)
        ])
        
        captionLabel.setAnchor(top: photoImageView.bottomAnchor, constantTop: 12,
                               leading: photoImageView.leadingAnchor)
        
        creationDateLabel.setAnchor(bottom: bottomAnchor, constantBottom: 7,
                                    trailing: trailingAnchor, constantTrailing: 12)
    }
    
    func configurePhotoImageView(image: UIImage?, caption: String?, creationDate: String) {
        photoImageView.image = image
        captionLabel.text = caption
        creationDateLabel.text = creationDate
    }
}

// TODO: - PreConcurrency 제거..?
extension MHPolaroidPhotoView: @preconcurrency MediaAttachable {
    func configureSource(with mediaDescription: MediaDescription, data: Data) {
        var caption: String?
        if let captionString = mediaDescription.attributes?[Constant.photoCaption] as? String {
            caption = captionString
        }
        let photoImage = UIImage(data: data)
        guard let creationDate = mediaDescription.attributes?[Constant.photoCreationDate] as? String else { return }
        
        configurePhotoImageView(image: photoImage, caption: caption, creationDate: creationDate)
    }
    
    func configureSource(with mediaDescription: MediaDescription, url: URL) {
        var caption: String?
        if let captionString = mediaDescription.attributes?[Constant.photoCaption] as? String {
            caption = captionString
        }
        let photoImage = UIImage(contentsOfFile: url.path)
        guard let creationDate = mediaDescription.attributes?[Constant.photoCreationDate] as? String else { return }
        
        configurePhotoImageView(image: photoImage, caption: caption, creationDate: creationDate)
    }
}
