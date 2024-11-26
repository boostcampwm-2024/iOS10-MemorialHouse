import UIKit

final class MHPolaroidPhotoView: UIView {
    
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .ownglyphBerry(size: 12)
        
        return label
    }()
    
    private let creationDateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .right
        label.font = .ownglyphBerry(size: 12)
        
        return label
    }()
    
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
    
    private func setup() {
        frame.size = CGSize(width: 310, height: 310)
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.masksToBounds = false
    }
    
    private func configureAddSubviews() {
        addSubview(photoImageView)
        addSubview(captionLabel)
        addSubview(creationDateLabel)
    }
    
    private func configureConstraints() {
        photoImageView.setAnchor(top: topAnchor, constantTop: 25, width: 210, height: 280)
        photoImageView.setCenterX(view: self)
        
        captionLabel.setAnchor(top: photoImageView.bottomAnchor, constantTop: 12)
        captionLabel.setCenterX(view: self)
        
        creationDateLabel.setAnchor(bottom: bottomAnchor, constantBottom: 7,
                                    trailing: trailingAnchor, constantTrailing: 12)
    }
    
    func configurePhotoImageView(image: UIImage, caption: String, creationDate: String) {
        photoImageView.image = image
        captionLabel.text = caption
        creationDateLabel.text = creationDate
    }
}
