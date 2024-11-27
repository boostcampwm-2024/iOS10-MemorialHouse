import Foundation

struct SettingViewModel {
    let tableViewDataSource = [
        "서비스 이용 약관",
        "개인정보 처리 방침",
        "불편신고 및 개선요청",
        "자주 묻는 질문 (FAQ)",
        "앱 버전"
    ]
    
    var appVersion: String? {
        guard let dictionary = Bundle.main.infoDictionary else { return nil}
        return dictionary["CFBundleShortVersionString"] as? String
    }
}
