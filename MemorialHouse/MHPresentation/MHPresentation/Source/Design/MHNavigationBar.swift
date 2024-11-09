import UIKit

final class MHNavigationBar: UIView {
    // MARK: - Property
    private let titleLabel = UILabel(style: .header)
    private let settingImageView = UIImageView(image: .settingLight)
    
    // MARK: - Initializer
    init(title: String) {
        super.init(frame: .zero)
        
        setup(with: title)
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup(with: "")
        configureConstraints()
    }
    
    // MARK: - Setup & Configuration
    func setup(with title: String) {
        titleLabel.text = "\(title) 기록소"
        backgroundColor = .baseBackground
        addSubview(titleLabel)
        addSubview(settingImageView)
    }
    
    func configureConstraints() {
        titleLabel.setTop(anchor: topAnchor)
        titleLabel.setLeading(anchor: leadingAnchor)
        titleLabel.setBottom(anchor: bottomAnchor)
        titleLabel.setCenterY(view: settingImageView)
        
        settingImageView.setTop(anchor: topAnchor)
        settingImageView.setTrailing(anchor: trailingAnchor)
        settingImageView.setCenterY(view: self)
        settingImageView.setWidth(30)
        settingImageView.setHeight(30)
    }
}
