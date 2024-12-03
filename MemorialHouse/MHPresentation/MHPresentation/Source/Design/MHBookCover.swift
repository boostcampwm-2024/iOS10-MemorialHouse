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
        let imageView = UIImageView(image: UIImage(systemName: "person.crop.square"))
        imageView.contentMode = .scaleAspectFit
        
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
        targetImageView.image = UIImage(systemName: "person.crop.square")
    }
    
    // MARK: - Configuration
    func configure(
        title: String? = nil,
        bookCoverImage: UIImage? = nil,
        targetImage: UIImage? = nil,
        houseName: String? = nil
    ) {
        if let title {
            bookTitleLabel.text = title
        }
        if let bookCoverImage {
            bookCoverImageView.image = bookCoverImage
        }
        if let targetImage {
            targetImageView.image = targetImage.withAlignmentRectInsets(
                UIEdgeInsets(
                    top: -5,
                    left: -5,
                    bottom: -5,
                    right: -5
                )
            )
        }
        if let houseName {
            houseLabel.text = houseName
        }
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
        targetImageView.setAnchor(
            leading: bookTitleLabel.leadingAnchor, constantLeading: 5,
            trailing: bookTitleLabel.trailingAnchor, constantTrailing: 5
        )
        houseLabel.setBottom(anchor: bottomAnchor, constant: 12)
        houseLabel.setTrailing(anchor: trailingAnchor, constant: 12)
        NSLayoutConstraint.activate([
            targetImageView.centerXAnchor.constraint(equalTo: bookTitleLabel.centerXAnchor, constant: 3),
            targetImageView.heightAnchor.constraint(equalTo: targetImageView.widthAnchor)
        ])
    }
}
