import MHFoundation

public enum MHDataError: Error, CustomStringConvertible, Equatable {
    case convertDTOFailure
    case fetchFaliure
    case findEntityFailure
    case saveContextFailure
    case directorySettingFailure
    case fileCreationFailure
    case fileReadingFailure
    case fileDeletionFailure
    case fileMovingFailure
    case fileNotExists
    
    public var description: String {
        switch self {
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
        case .fileNotExists:
            "파일이 존재하지 않습니다"
        }
    }
}
