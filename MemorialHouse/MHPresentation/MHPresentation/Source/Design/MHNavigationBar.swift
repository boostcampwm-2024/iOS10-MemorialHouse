import UIKit

final class MHNavigationBar: UIView {
    // MARK: - Property
    private let titleLabel = UILabel(style: .header1)
    private let settingButton = UIButton(type: .custom)
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        
        setup()
        configureAddSubView()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
        configureAddSubView()
        configureConstraints()
    }
    
    // MARK: - Setup & Configuration
    private func setup() {
        settingButton.setImage(.settingLight, for: .normal)
        backgroundColor = .baseBackground
    }
    
    private func configureAddSubView() {
        addSubview(titleLabel)
        addSubview(settingButton)
    }
    
    private func configureConstraints() {
        titleLabel.setTop(anchor: topAnchor)
        titleLabel.setLeading(anchor: leadingAnchor)
        titleLabel.setBottom(anchor: bottomAnchor)
        titleLabel.setCenterY(view: settingButton)
        
        settingButton.setTop(anchor: topAnchor)
        settingButton.setTrailing(anchor: trailingAnchor)
        settingButton.setCenterY(view: self)
        settingButton.setWidth(30)
        settingButton.setHeight(30)
    }
    
    func configureSettingAction(action: UIAction) {
        settingButton.addAction(action, for: .touchUpInside)
    }
    
    func configureTitle(with title: String) {
        let localizedKey = "UserName 기록소"
        titleLabel.text = String.localizedStringWithFormat(localizedKey.localized(), title)
    }
}
