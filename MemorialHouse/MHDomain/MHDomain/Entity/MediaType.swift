public enum MediaType: String, Sendable {
    case image
    case video
    case audio
    
    var defaultFileExtension: String {
        switch self {
        case .image:
            return "png"
        case .video:
            return "mp4"
        case .audio:
            return "m4a"
        }
    }
}
