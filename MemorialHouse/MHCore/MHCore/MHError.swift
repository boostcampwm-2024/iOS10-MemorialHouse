import Foundation

public enum MHError: Error, CustomStringConvertible {
    case DIContainerResolveFailure(key: String)
    case convertDTOFailure
    case findEntityFailure
    case saveContextFailure
    
    public var description: String {
        switch self {
        case .DIContainerResolveFailure(let key):
            "\(key)에 대한 dependency resolve 실패"
        case .convertDTOFailure:
            "Entity에 대한 DTO 변환 실패"
        case .findEntityFailure:
            "Entity 찾기 실패"
        case .saveContextFailure:
            "Update된 Context 저장 실패"
        }
    }
}
