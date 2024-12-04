import UIKit

extension UIView {
    /// 뷰에 빨간 테두리와 배경을 추가한 뷰를 반환해줍니다.
    /// - Parameter insets: border와 content사이의 간격입니다.
    /// - Returns: 배경 스타일이 적용된 새로운 뷰
    func embededInDefaultBackground(
        with insets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    ) -> UIView {
        let borderView = UIView()
        borderView.backgroundColor = .clear
        borderView.layer.cornerRadius = 17
        borderView.layer.borderWidth = 1.5
        borderView.layer.borderColor = UIColor.mhBorder.cgColor
        borderView.clipsToBounds = true
        borderView.addSubview(self)
        self.setAnchor(
            top: borderView.topAnchor, constantTop: insets.top,
            leading: borderView.leadingAnchor, constantLeading: insets.left,
            bottom: borderView.bottomAnchor, constantBottom: insets.bottom,
            trailing: borderView.trailingAnchor, constantTrailing: insets.right
        )
        
        let backGroundView = UIView()
        backGroundView.backgroundColor = .mhSection
        backGroundView.layer.cornerRadius = 20
        backGroundView.clipsToBounds = true
        backGroundView.addSubview(borderView)
        borderView.setAnchor(
            top: backGroundView.topAnchor, constantTop: 6,
            leading: backGroundView.leadingAnchor, constantLeading: 7,
            bottom: backGroundView.bottomAnchor, constantBottom: 6,
            trailing: backGroundView.trailingAnchor, constantTrailing: 7
        )
        
        return backGroundView
    }
    
    /// 뷰의 왼쪽 / 오른쪽에 String으로 입력받은 텍스트를 추가합니다.
    /// 글꼴은 default를 사용합니다.
    /// 5포인트의 간격을 갖습니다.
    /// - Parameters:
    ///   - leftTitle: 왼쪽에 넣을 텍스트
    ///   - rightTitle: 오른쪽에 넣을 텍스트
    /// - Returns: 해당 텍스트가 추가된 새로운 뷰
    func titledContentView(leftTitle: String? = nil, rightTitle: String? = nil) -> UIView {
        let wrappedView = UIStackView(arrangedSubviews: [self])
        wrappedView.axis = .horizontal
        wrappedView.distribution = .fill
        wrappedView.alignment = .fill
        wrappedView.spacing = 5
        
        if let leftTitle {
            let leftLabel = UILabel(style: .header2)
            leftLabel.text = leftTitle
            leftLabel.setContentHuggingPriority(UILayoutPriority(751), for: .horizontal)
            leftLabel.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
            
            wrappedView.insertArrangedSubview(leftLabel, at: 0)
        }
        if let rightTitle {
            let rightLabel = UILabel(style: .header2)
            rightLabel.text = rightTitle
            rightLabel.setContentHuggingPriority(UILayoutPriority(752), for: .horizontal)
            rightLabel.setContentCompressionResistancePriority(UILayoutPriority(752), for: .horizontal)
            
            wrappedView.addArrangedSubview(rightLabel)
        }
        
        return wrappedView
    }
}
