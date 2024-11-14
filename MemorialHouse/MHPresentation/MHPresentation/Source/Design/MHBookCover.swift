import UIKit
import MHFoundation
import MHDomain

final class MHBookCover: UIView {
    // MARK: - Property
    private let bookCoverImageView = UIImageView()
    private let titleLabel = UILabel(style: .default)
    private let targetImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.layer.shadowRadius = 4
        imageView.layer.shadowOpacity = 0.4
        imageView.layer.shadowOffset = CGSize(width: 4, height: 4)
        
        return imageView
    }()
    private let houseLabel = UILabel(style: .body2)
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        
        configureAddSubView()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureAddSubView()
        configureConstraints()
    }
    
    func resetProperties() {
        bookCoverImageView.image = nil
        titleLabel.text = nil
        targetImageView.image = nil
    }
    
    // MARK: - Configuration
    func configure(
        title: String,
        bookCoverImage: UIImage,
        targetImage: UIImage,
        houseName: String
    ) {
        titleLabel.text = title
        bookCoverImageView.image = bookCoverImage
        targetImageView.image = targetImage
        houseLabel.text = houseName
    }
    
    private func configureAddSubView() {
        addSubview(bookCoverImageView)
        addSubview(titleLabel)
        addSubview(targetImageView)
        addSubview(houseLabel)
    }
    
    private func configureConstraints() {
        bookCoverImageView.fillSuperview()
        titleLabel.setTop(anchor: topAnchor, constant: 16)
        titleLabel.setCenterX(view: self, constant: 8)
        targetImageView.setTop(anchor: titleLabel.bottomAnchor, constant: 14)
        targetImageView.setCenterX(view: self, constant: 8)
        targetImageView.setWidthAndHeight(width: 100, height: 110)
        houseLabel.setBottom(anchor: bottomAnchor, constant: 12)
        houseLabel.setTrailing(anchor: trailingAnchor, constant: 12)
    }
}
