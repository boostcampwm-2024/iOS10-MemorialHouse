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
        configureAction()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureAddSubView()
        configureAction()
        configureConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        bookCoverView.prepareForReuse()
        likeButton.imageView?.image = nil
    }
    
    // MARK: - Configuration
    func configure(
        title: String,
        bookCoverImage: UIImage,
        targetImage: UIImage,
        isLike: Bool,
        // category: String, // TODO: 카테고리 처리 생각해보기
        houseName: String
    ) {
        bookCoverView.configure(
            title: title,
            bookCoverImage: bookCoverImage,
            targetImage: targetImage,
            houseName: houseName
        )
        likeButton.setImage(isLike ? .likeFill : .likeEmpty, for: .normal)
        dropDownButton.setImage(.dotHorizontal, for: .normal)
    }
    
    private func configureAddSubView() {
        contentView.addSubview(bookCoverView)
        contentView.addSubview(likeButton)
        contentView.addSubview(dropDownButton)
    }
    
    private func configureAction() {
        likeButton.addAction(UIAction { _ in
            // TODO: 좋아요 버튼 로직
        }, for: .touchUpInside)
        
        dropDownButton.addAction(UIAction { _ in
            // TODO: UI Menu 띄우기
        }, for: .touchUpInside)
    }
    
    private func configureConstraints() {
        bookCoverView.fillSuperview()
        likeButton.setAnchor(
            top: bookCoverView.bottomAnchor,
            trailing: dropDownButton.leadingAnchor, constantTrailing: 4,
            width: 20, height: 20
        )
        dropDownButton.setAnchor(
            top: bookCoverView.bottomAnchor, constantTop: 2,
            trailing: contentView.trailingAnchor, constantTrailing: 4,
            width: 20, height: 16
        )
    }
}
