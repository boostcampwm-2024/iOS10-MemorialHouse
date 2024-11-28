public struct BookCategory: Sendable {
    public let order: Int
    public let name: String
    
    public init(
        order: Int,
        name: String
    ) {
        self.order = order
        self.name = name
    }
}
