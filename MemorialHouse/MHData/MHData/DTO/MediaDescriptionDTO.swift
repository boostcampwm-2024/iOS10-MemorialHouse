import MHFoundation
import MHDomain


public struct MediaDescriptionDTO {
    let id: UUID
    let type: String
    
    func toMediaDescription() -> MediaDescription? {
        guard let type = MediaType(rawValue: self.type) else { return nil }
        
        return MediaDescription(
            id: self.id,
            type: type
        )
    }
}
