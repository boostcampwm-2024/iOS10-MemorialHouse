import Foundation

public enum MHError: Error, CustomStringConvertible, Equatable {
    case DIContainerResolveFailure(key: String)
    case convertDTOFailure
    case fetchFaliure
    case findEntityFailure
    case saveContextFailure
    case directorySettingFailure
    case fileCreationFailure
    case fileReadingFailure
    case fileDeletionFailure
    case fileMovingFailure
    
    public var description: String {
        switch self {
        case .DIContainerResolveFailure(let key):
            "\(key)에 대한 dependency resolve 실패"
        case .convertDTOFailure:
            "Entity에 대한 DTO 변환 실패"
        case .fetchFaliure:
            "Entity Fetch 실패"
        case .findEntityFailure:
            "Entity 찾기 실패"
        case .saveContextFailure:
            "Update된 Context 저장 실패"
        case .directorySettingFailure:
            "디렉토리 설정 실패"
        case .fileCreationFailure:
            "파일 생성 실패"
        case .fileReadingFailure:
            "파일 읽기 실패"
        case .fileDeletionFailure:
            "파일 삭제 실패"
        case .fileMovingFailure:
            "파일 이동 실패"
        }
    }
}
