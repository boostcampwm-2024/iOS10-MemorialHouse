import MHFoundation
import MHDomain

public struct MediaDescriptionDTO {
    let id: UUID
    let type: String
    let attributes: Data?
    
    public init(
        id: UUID,
        type: String,
        attributes: Data?
    ) {
        self.id = id
        self.type = type
        self.attributes = attributes
    }
    
    func convertToMediaDescription() -> MediaDescription? {
        guard let type = MediaType(rawValue: self.type) else { return nil }
        let attributes = try? JSONSerialization.jsonObject(with: attributes ?? Data(), options: []) as? [String: any Sendable]
        
        return MediaDescription(
            id: self.id,
            type: type,
            attributes: attributes
        )
    }
}
