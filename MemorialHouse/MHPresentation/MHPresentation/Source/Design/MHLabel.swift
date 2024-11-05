import UIKit

final class MHLabel: UILabel {
    private let alignment: NSTextAlignment
    private var color: UIColor
    private var labelText: String
    
    /// - Parameters:
    ///   - frame: 레이블의 프레임. 기본값은 `.zero`입니다.
    ///   - labelText: 레이블에 표시될 텍스트. 기본값은 빈 문자열입니다.
    ///   - alignment: 텍스트 정렬 방식. 기본값은 `.justified`입니다.
    ///   - color: 텍스트 색상. 기본값은 `UIColor.black`입니다.
    
    init(
        frame: CGRect = .zero,
        labelText: String = "",
        alignment: NSTextAlignment = .justified,
        color: UIColor = .black
    ) {
        self.labelText = labelText
        self.alignment = alignment
        self.color = color
        super.init(frame: frame)
        
        guard let font = UIFont(name: "Ownglyph_BERRY_RW-Rg", size: 25) else { return }
        self.font = font
        setupAttributes()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        self.labelText = ""
        self.alignment = .justified
        self.color = .black
        super.init(coder: coder)
        
        guard let font = UIFont(name: "Ownglyph_BERRY_RW-Rg", size: 25) else { return }
        self.font = font
        setupAttributes()
    }
    
    private func setupAttributes() {
        let attributedString = NSMutableAttributedString(string: labelText)
        let range = NSRange(location: 0, length: attributedString.length)
        
        // 폰트 설정
        guard let font = UIFont(name: "Ownglyph_BERRY_RW-Rg", size: 25) else { return }
        attributedString.addAttribute(
            .font,
            value: font,
            range: range
        )
        
        // 텍스트 색상 설정
        attributedString.addAttribute(
            .foregroundColor,
            value: color,
            range: range
        )
        
        // 텍스트 정렬 설정
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: range
        )
        
        attributedText = attributedString
    }
}
