import MHFoundation
import MHDomain

public struct PageDTO {
    let id: UUID
    let metadata: [Int: MediaDescriptionDTO]
    let text: String
    
    public init(id: UUID, metadata: [Int : MediaDescriptionDTO], text: String) {
        self.id = id
        self.metadata = metadata
        self.text = text
    }
    
    func toPage() -> Page {
        let metadata = self.metadata
            .compactMapValues { $0.toMediaDescription() }
        
        return Page(
            id: self.id,
            metadata: metadata,
            text: self.text
        )
    }
}
