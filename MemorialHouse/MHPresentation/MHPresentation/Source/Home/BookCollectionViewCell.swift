import UIKit

final class BookCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    private let bookCoverView = MHBookCover()
    private let likeButton = UIButton(type: .custom)
    private let dropDownButton = UIButton(type: .custom)
    private var isLike: Bool = false
    
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
        likeButton.removeTarget(nil, action: nil, for: .allEvents)
    }
    
    // MARK: - Configuration
    func configure(
        id: UUID,
        title: String,
        bookCoverImage: UIImage,
        targetImage: UIImage,
        isLike: Bool,
        houseName: String,
        bookCoverAction: @escaping () -> Void,
        likeButtonAction: @escaping () -> Void
    ) {
        self.isLike = isLike
        bookCoverView.configure(
            title: title,
            bookCoverImage: bookCoverImage,
            targetImage: targetImage,
            houseName: houseName
        )
        changeLikeButtonImage(isLike: isLike)
        dropDownButton.setImage(.dotHorizontal, for: .normal)
        configureAction(
            bookCoverAction: bookCoverAction,
            likeButtonAction: likeButtonAction
        )
    }
    
    private func configureAction(
        bookCoverAction: @escaping () -> Void,
        likeButtonAction: @escaping () -> Void
    ) {
        bookCoverView.addAction(UIAction { _ in
            bookCoverAction()
        }, for: .touchUpInside)
        
        likeButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            likeButtonAction()
            self.isLike.toggle()
            self.changeLikeButtonImage(isLike: self.isLike)
        }, for: .touchUpInside)
        
        dropDownButton.addAction(UIAction { _ in
        }, for: .touchUpInside)
    }
    
    private func changeLikeButtonImage(isLike: Bool) {
        let likeImage = UIImage.resizedImage(
            image: isLike ? .likeFill : .likeEmpty,
            size: CGSize(width: 28, height: 28)
        )
        likeButton.setImage(likeImage, for: .normal)
    }
    
    private func configureAddSubView() {
        contentView.addSubview(bookCoverView)
        contentView.addSubview(likeButton)
        contentView.addSubview(dropDownButton)
    }
    
    private func configureConstraints() {
        bookCoverView.setAnchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            bottom: likeButton.topAnchor,
            trailing: contentView.trailingAnchor
        )
        likeButton.setAnchor(
            bottom: contentView.bottomAnchor,
            trailing: dropDownButton.leadingAnchor, constantTrailing: 10,
            width: 28, height: 28
        )
        dropDownButton.setAnchor(
            trailing: contentView.trailingAnchor, constantTrailing: 4,
            width: 24, height: 16
        )
        dropDownButton.setCenterY(view: likeButton)
    }
}
