public enum BookColor: String, Sendable {
    case pink
    case green
    case blue
    case orange
    case beige
    
    public var index: Int {
        switch self {
        case .pink: 
            return 0
        case .green:
            return 1
        case .blue:
            return 2
        case .orange:
            return 3
        case .beige:
            return 4
        }
    }
    
    public static func indexToColor(index: Int) -> BookColor {
        let colors: [BookColor] = [.pink, .green, .blue, .orange, .beige]
        return colors[index]
    }
}
