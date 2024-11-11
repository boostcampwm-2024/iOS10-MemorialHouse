import UIKit
import MHFoundation
import MHDomain

// TODO: 위치 변경 고려해보기
extension BookType {
    var image: UIImage {
        switch self {
        case .blue: .blueBook
        case .beige: .beigeBook
        case .green: .greenBook
        case .orange: .orangeBook
        case .pink: .pinkBook
        @unknown default:
            fatalError("등록되지 않은 책 색상입니다.")
        }
    }
}

final class MHBook: UIView {
    // MARK: - Property
    private let containerView = UIView()
    private let bookImageView = UIImageView()
    private let titleLabel = UILabel(style: .default)
    private let targetImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
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
    func configure(with bookCover: BookCover) {
        titleLabel.text = bookCover.title
        bookImageView.image = bookCover.bookType.image
        targetImageView.image = UIImage(systemName: "person") // TODO: Image Loader로 변경
        if let publisher = UserDefaults.standard.object(forKey: Constant.houseNameUserDefaultKey) as? String {
            // TODO: User 모델 만들어지면 파라미터로 출판소 이름 넘겨주기
            publisherLabel.text = publisher
        }
    }
    
    private func configureAddSubView() {
        addSubview(containerView)
        containerView.addSubview(bookImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(targetImageView)
        containerView.addSubview(publisherLabel)
    }
    
    private func configureConstraints() {
        containerView.fillSuperview()
        bookImageView.fillSuperview()
        titleLabel.setTop(anchor: containerView.topAnchor, constant: 16)
        titleLabel.setCenterX(view: containerView, constant: 8)
        targetImageView.setTop(anchor: titleLabel.bottomAnchor, constant: 14)
        targetImageView.setCenterX(view: containerView, constant: 8)
        targetImageView.setWidthAndHeight(width: 100, height: 100)
        publisherLabel.setBottom(anchor: containerView.bottomAnchor, constant: 12)
        publisherLabel.setTrailing(anchor: containerView.trailingAnchor, constant: 12)
    }
}
