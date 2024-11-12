import UIKit
import MHFoundation
import MHDomain

final class MHBook: UIView {
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
    private let publisherLabel = UILabel(style: .body2)
    
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
    
    // MARK: - Configuration
    func configure(
        title: String,
        bookCoverImage: UIImage,
        targetImage: UIImage,
        publisher: String
    ) {
        titleLabel.text = title
        bookCoverImageView.image = bookCoverImage
        targetImageView.image = targetImage
        publisherLabel.text = publisher
    }
    
    private func configureAddSubView() {
        addSubview(bookCoverImageView)
        addSubview(titleLabel)
        addSubview(targetImageView)
        addSubview(publisherLabel)
    }
    
    private func configureConstraints() {
        bookCoverImageView.fillSuperview()
        titleLabel.setTop(anchor: topAnchor, constant: 16)
        titleLabel.setCenterX(view: self, constant: 8)
        targetImageView.setTop(anchor: titleLabel.bottomAnchor, constant: 14)
        targetImageView.setCenterX(view: self, constant: 8)
        targetImageView.setWidthAndHeight(width: 100, height: 100)
        publisherLabel.setBottom(anchor: bottomAnchor, constant: 12)
        publisherLabel.setTrailing(anchor: trailingAnchor, constant: 12)
    }
}
