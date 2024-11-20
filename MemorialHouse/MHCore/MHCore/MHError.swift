import Foundation

public enum MHError: Error, CustomStringConvertible {
    case DIContainerResolveFailure(key: String)
    
    public var description: String {
        switch self {
        case .DIContainerResolveFailure(let key):
            "\(key)에 대한 dependency resolve 실패"
        }
    }
}
