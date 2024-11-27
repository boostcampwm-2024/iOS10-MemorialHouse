import MHFoundation

public enum MHCoreError: Error, CustomStringConvertible, Equatable {
    case DIContainerResolveFailure(key: String)
    
    public var description: String {
        switch self {
        case .DIContainerResolveFailure(let key):
            "\(key)에 대한 dependency resolve 실패"
        }
    }
}
