import UIKit

final class BookCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    private let bookCoverView = MHBookCover()
    private let likeButton = UIButton(type: .custom)
    private let dropDownButton = UIButton(type: .custom)
    private var isLike: Bool = false
    private var bookCoverAction: UIAction?
    private var likeButtonAction: UIAction?
    
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
        dropDownButton.menu = nil
        if let bookCoverAction {
            bookCoverView.removeAction(bookCoverAction, for: .touchUpInside)
        }
        if let likeButtonAction {
            likeButton.removeAction(likeButtonAction, for: .touchUpInside)
        }
    }
    
    // MARK: - Configuration
    func configureCell(
        id: UUID,
        title: String,
        bookCoverImage: UIImage,
        targetImage: UIImage?,
        isLike: Bool,
        houseName: String
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
    }
    
    func configureButtonAction(
        bookCoverAction: @escaping () -> Void,
        likeButtonAction: @escaping () -> Void,
        dropDownButtonEditAction: @escaping () -> Void,
        dropDownButtonDeleteAction: @escaping () -> Void
    ) {
        self.bookCoverAction = UIAction { _ in
            bookCoverAction()
        }
        if let bookCoverAction = self.bookCoverAction {
            bookCoverView.addAction(bookCoverAction, for: .touchUpInside)
        }
        self.likeButtonAction = UIAction { [weak self] _ in
            guard let self else { return }
            likeButtonAction()
            self.isLike.toggle()
            self.changeLikeButtonImage(isLike: self.isLike)
        }
        if let likeButtonAction = self.likeButtonAction {
            likeButton.addAction(likeButtonAction, for: .touchUpInside)
        }
        dropDownButton.showsMenuAsPrimaryAction = true
        dropDownButton.menu = UIMenu(
            title: "",
            children: [
                UIAction(
                    title: "책 커버 수정",
                    image: UIImage(systemName: "pencil"),
                    handler: { _ in dropDownButtonEditAction() }
                ),
                UIAction(
                    title: "책 커버 삭제",
                    image: UIImage(systemName: "trash"),
                    attributes: .destructive,
                    handler: { _ in dropDownButtonDeleteAction() }
                )
            ]
        )
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
