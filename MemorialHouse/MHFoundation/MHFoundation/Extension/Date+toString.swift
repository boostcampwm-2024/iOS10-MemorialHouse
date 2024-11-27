import Foundation

public extension Date {
    /// Date 타입을 yyyy.MM.dd 형태의 String으로 변환하여 반환합니다.
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        
        return formatter.string(from: self)
    }
}
