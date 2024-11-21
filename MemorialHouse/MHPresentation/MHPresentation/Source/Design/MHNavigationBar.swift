import UIKit

final class MHNavigationBar: UIView {
    // MARK: - Property
    private let titleLabel = UILabel(style: .header1)
    private let settingButton = UIButton(type: .custom)
    
    // MARK: - Initializer
    init(title: String) {
        super.init(frame: .zero)
        
        setup(with: title)
        configureAddSubView()
        configureConstraints()
        configureAction()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup(with: "")
        configureAddSubView()
        configureConstraints()
        configureAction()
    }
    
    // MARK: - Setup & Configuration
    private func setup(with title: String) {
        titleLabel.text = "\(title) 기록소"
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
    
    private func configureAction() {
        settingButton.addAction(UIAction { _ in
            // TODO: 설정 버튼 클릭 시 설정화면 라우팅 필요
        }, for: .touchUpInside)
    }
}
