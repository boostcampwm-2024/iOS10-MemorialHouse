import UIKit

final class CategoryTableViewCell: UITableViewCell {
    nonisolated static let height: CGFloat = 44
    
    // MARK: - UI Components
    private let categoryLabel = UILabel(style: .body1)
    private let checkImageView = UIImageView()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
        configureLayout()
    }
    
    // MARK: - Setup & Configuration
    func configure(category: String, isSelected: Bool) {
        categoryLabel.text = category
        checkImageView.image = isSelected ? .check : nil
    }
    
    private func setup() {
        contentView.backgroundColor = .baseBackground
        contentView.addSubview(categoryLabel)
        contentView.addSubview(checkImageView)
        checkImageView.contentMode = .scaleAspectFit
    }
    
    private func configureLayout() {
        categoryLabel.setLeading(anchor: contentView.leadingAnchor, constant: 16)
        categoryLabel.setCenterY(view: contentView)
        checkImageView.setTrailing(anchor: contentView.trailingAnchor, constant: 16)
        checkImageView.setCenterY(view: contentView)
    }
}
