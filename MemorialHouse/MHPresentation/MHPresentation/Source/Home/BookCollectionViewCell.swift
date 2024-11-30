import UIKit

final class BookCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    private let bookCoverView = MHBookCover()
    private let likeButton = UIButton(type: .custom)
    private let dropDownButton = UIButton(type: .custom)
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureAddSubView()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureAddSubView()
        configureConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        bookCoverView.resetProperties()
        likeButton.imageView?.image = nil
    }
    
    // MARK: - Configuration
    func configure(
        id: UUID,
        title: String,
        bookCoverImage: UIImage,
        targetImage: UIImage,
        isLike: Bool,
        houseName: String,
        likeButtonAction: @escaping () -> Void
        // TODO: DropDownButtonAction
    ) {
        bookCoverView.configure(
            title: title,
            bookCoverImage: bookCoverImage,
            targetImage: targetImage,
            houseName: houseName
        )

        let likeImage = UIImage.resizedImage(
            image: isLike ? .likeFill : .likeEmpty,
            size: CGSize(width: 28, height: 28)
        )
        likeButton.setImage(likeImage, for: .normal)
        dropDownButton.setImage(.dotHorizontal, for: .normal)
        
        configureAction(likeButtonAction: likeButtonAction)
    }
    
    private func configureAddSubView() {
        contentView.addSubview(bookCoverView)
        contentView.addSubview(likeButton)
        contentView.addSubview(dropDownButton)
    }
    
    private func configureAction(likeButtonAction: @escaping () -> Void) {
        likeButton.addAction(UIAction { _ in
            likeButtonAction()
        }, for: .touchUpInside)
        
        dropDownButton.addAction(UIAction { _ in
            // TODO: DropDownButtonAction
        }, for: .touchUpInside)
    }
    
    private func configureConstraints() {
        bookCoverView.fillSuperview()
        likeButton.setAnchor(
            top: bookCoverView.bottomAnchor,
            trailing: dropDownButton.leadingAnchor, constantTrailing: 10
        )
        dropDownButton.setAnchor(
            trailing: contentView.trailingAnchor, constantTrailing: 4,
            width: 24, height: 16
        )
        dropDownButton.setCenterY(view: likeButton)
    }
}
