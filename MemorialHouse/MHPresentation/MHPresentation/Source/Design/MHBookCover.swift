import UIKit
import MHFoundation
import MHDomain

final class MHBookCover: UIButton {
    // MARK: - Property
    private let bookCoverImageView = UIImageView()
    private let bookTitleLabel: UILabel = {
        let label = UILabel(style: .header2)
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    private let targetImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.layer.shadowRadius = 4
        imageView.layer.shadowOpacity = 0.4
        imageView.layer.shadowOffset = CGSize(width: 4, height: 4)
        
        return imageView
    }()
    private let houseLabel = UILabel(style: .body3)
    
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
        bookTitleLabel.text = nil
        targetImageView.image = nil
    }
    
    // MARK: - Configuration
    func configure(
        title: String,
        bookCoverImage: UIImage,
        targetImage: UIImage,
        houseName: String
    ) {
        bookTitleLabel.text = title
        bookCoverImageView.image = bookCoverImage
        targetImageView.image = targetImage
        houseLabel.text = houseName
    }
    
    private func configureAddSubView() {
        addSubview(bookCoverImageView)
        addSubview(bookTitleLabel)
        addSubview(targetImageView)
        addSubview(houseLabel)
    }
    
    private func configureConstraints() {
        bookCoverImageView.fillSuperview()
        bookTitleLabel.setTop(anchor: topAnchor, constant: 16)
        bookTitleLabel.setLeading(anchor: leadingAnchor, constant: 25)
        bookTitleLabel.setTrailing(anchor: trailingAnchor, constant: 12)
        targetImageView.setTop(anchor: bookTitleLabel.bottomAnchor, constant: 14)
        targetImageView.setCenterX(view: self, constant: 8)
        targetImageView.setWidthAndHeight(width: 100, height: 110)
        houseLabel.setBottom(anchor: bottomAnchor, constant: 12)
        houseLabel.setTrailing(anchor: trailingAnchor, constant: 12)
    }
}
