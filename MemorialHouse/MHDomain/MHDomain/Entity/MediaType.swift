public enum MediaType: String, Sendable {
    case image
    case video
    case audio
    
    /// 기본 파일 확장자를 반환합니다.
    /// 사진은 .png, 비디오는 .mp4, 오디오는 .m4a를 반환합니다.
    public var defaultFileExtension: String {
        switch self {
        case .image:
            return ".png"
        case .video:
            return ".mp4"
        case .audio:
            return ".m4a"
        }
    }
}
