import Foundation

public enum MHError: Error, CustomStringConvertible, Equatable {
    case DIContainerResolveFailure(key: String)
    case convertDTOFailure
    case findEntityFailure
    case saveContextFailure
    case directorySettingError
    case fileCreationError
    case fileReadingError
    case fileDeletionError
    case fileMovingError
    
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
        case .directorySettingError:
            "디렉토리 설정 실패"
        case .fileCreationError:
            "파일 생성 실패"
        case .fileReadingError:
            "파일 읽기 실패"
        case .fileDeletionError:
            "파일 삭제 실패"
        case .fileMovingError:
            "파일 이동 실패"
        }
    }
}
