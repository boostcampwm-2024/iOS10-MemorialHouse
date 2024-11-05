import UIKit

final class MHLabel: UILabel {
    private let labelText: String
    private let size: CGFloat
    private let alignment: NSTextAlignment
    private let color: UIColor
    
    private var customFont: UIFont? {
        return UIFont(name: "Ownglyph_BERRY_RW-Rg", size: size)
    }
    
    /// - Parameters:
    ///   - frame: 레이블의 프레임. 기본값은 `.zero`입니다.
    ///   - labelText: 레이블에 표시될 텍스트. 기본값은 빈 문자열입니다.
    ///   - size: 레이블 텍스트의 크기. 기본값은 25입니다.
    ///   - alignment: 텍스트 정렬 방식. 기본값은 `.justified`입니다.
    ///   - color: 텍스트 색상. 기본값은 `UIColor.black`입니다.
    init(
        frame: CGRect = .zero,
        labelText: String = "",
        size: CGFloat = 25,
        alignment: NSTextAlignment = .justified,
        color: UIColor = .black
    ) {
        self.labelText = labelText
        self.size = size
        self.alignment = alignment
        self.color = color
        super.init(frame: frame)
        self.font = customFont
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        self.labelText = ""
        self.size = 25
        self.alignment = .justified
        self.color = .black
        super.init(coder: coder)
        self.font = customFont
        setup()
    }
    
    private func setup() {
        self.font = customFont
        self.textColor = color
        self.textAlignment = alignment
        self.text = labelText
    }
}
