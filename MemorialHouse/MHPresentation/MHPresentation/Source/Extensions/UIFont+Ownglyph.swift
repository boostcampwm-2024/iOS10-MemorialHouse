import UIKit

extension UIFont {
    static func ownglyphBerry(size: CGFloat) -> UIFont {
        return UIFont(name: "Ownglyph_BERRY_RW-Rg", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    public static func registerFont() {
        guard let url = Bundle(for: HomeViewController.self)
            .url(forResource: "OwnglyphBerry", withExtension: "ttf") else {
            // TODO: Logger로 처리
            print("폰트 파일을 찾을 수 없습니다.")
            return
        }
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
            // TODO: Logger로 처리
            print("폰트 등록 실패: \(error?.takeRetainedValue().localizedDescription ?? "알 수 없는 오류")")
        }
    }
}
