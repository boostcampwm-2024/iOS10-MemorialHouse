import MHFoundation
import MHDomain

public struct MediaDescriptionDTO {
    let id: UUID
    let type: String
    
    public init(id: UUID, type: String) {
        self.id = id
        self.type = type
    }
    
    func toMediaDescription() -> MediaDescription? {
        guard let type = MediaType(rawValue: self.type) else { return nil }
        
        return MediaDescription(
            id: self.id,
            type: type
        )
    }
}
