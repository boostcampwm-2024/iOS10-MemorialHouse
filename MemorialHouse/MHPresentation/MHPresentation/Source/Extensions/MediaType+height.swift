import MHDomain

extension MediaType {
    var height: Double {
        switch self {
        case .image:
            return 300
        case .video:
            return 400
        case .audio:
            return 100
        default:
            return 100
        }
    }
}
