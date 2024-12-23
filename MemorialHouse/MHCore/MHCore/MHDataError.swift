import MHFoundation

public enum MHDataError: Error, CustomStringConvertible, Equatable {
    case noSuchEntity(key: String)
    case createEntityFailure
    case convertDTOFailure
    case fetchEntityFaliure
    case updateEntityFailure
    case deleteEntityFailure
    case findEntityFailure
    case saveContextFailure
    case directorySettingFailure
    case fileCreationFailure
    case fileReadingFailure
    case fileDeletionFailure
    case fileMovingFailure
    case fileNotExists
    case snapshotEncodingFailure
    case snapshotDecodingFailure
    case generalFailure
    case setUserDefaultFailure
    
    public var description: String {
        switch self {
        case let .noSuchEntity(key):
            "\(key)에 대한 Entity가 존재하지 않습니다"
        case .createEntityFailure:
            "Entity 생성 실패"
        case .convertDTOFailure:
            "Entity에 대한 DTO 변환 실패"
        case .fetchEntityFaliure:
            "Entity 가져오기 실패"
        case .updateEntityFailure:
            "Entity 업데이트 실패"
        case .deleteEntityFailure:
            "Entity 삭제 실패"
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
        case .snapshotEncodingFailure:
            "Snapshot 인코딩 실패"
        case .snapshotDecodingFailure:
            "Snapshot 디코딩 실패"
        case .generalFailure:
            "알 수 없는 에러입니다."
        case .setUserDefaultFailure:
            "UserDefault 설정 실패"
        }
    }
}
