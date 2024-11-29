import MHFoundation
import MHCore

public protocol FileStorage: Sendable {
    /// 지정된 경로에 파일을 생성합니다.
    /// Documents폴더에 파일을 생성합니다.
    /// 중간 경로 폴더를 자동으로 생성합니다.
    /// - Parameters:
    ///   - path: Documents/{path} 이런식으로 들어갑니다.
    ///   - name: Documents/{path}/{name} 이런식으로 저장됩니다. (확장자 명시 필요)
    ///   - data: 실제 저장될 데이터
    /// - Returns: 성공여부를 반환합니다.
    func create(at path: String, fileName name: String, data: Data) async -> Result<Void, MHDataError>
    
    /// 지정된 경로의 파일을 읽어옵니다.
    /// Documents폴더에서 파일을 읽어옵니다
    /// - Parameters:
    ///   - path: Documents/{path} 이런식으로 들어갑니다.
    ///   - name: Documents/{path}/{name} 이런식으로 읽어옵니다. (확장자 명시 필요)
    /// - Returns: 파일 데이터를 반환합니다.
    func read(at path: String, fileName name: String) async -> Result<Data, MHDataError>
    
    /// 지정된 경로의 파일을 삭제합니다.
    /// Documents폴더에서 파일을 삭제합니다.
    /// - Parameters:
    ///   - path: Documents/{path} 이런식으로 들어갑니다.
    ///   - name: Documents/{path}/{name} 이런식으로 삭제합니다. (확장자 명시 필요)
    /// - Returns: 성공여부를 반환합니다.
    func delete(at path: String, fileName name: String) async -> Result<Void, MHDataError>
    
    /// 지정된 경로의 파일을 새로운 파일 이름으로 복사합니다.
    /// 지정된 경로 -> Documents폴더로 파일을 복사합니다.
    /// - Parameters:
    ///   - url: 내부 저장소의 파일 URL (AVURLAsset등의 URL호환)
    ///   - newPath: Documents/{newPath} 이런식으로 들어갑니다.
    ///   - name: Documents/{newPath}/{name} 이런식으로 저장됩니다. (확장자 명시 필요)
    /// - Returns: 성공여부를 반환합니다.
    func copy(at url: URL, to newPath: String, newFileName name: String) async -> Result<Void, MHDataError>
    
    /// 지정된 경로의 파일을 복사합니다.
    /// Documents폴더 -> Documents폴더로 파일을 복사합니다.
    /// Documents/{path}/{name} => Documents/{newPath}/{name} 이런식으로 복사합니다.
    /// - Parameters:
    ///   - path: Documents/{path} 이런식으로 들어갑니다
    ///   - name: Documents/{path}/{name} 이 파일을 복사합니다. (확장자 명시 필요)
    ///   - newPath: Documents/{newPath}/{name} 으로  저장합니다.
    /// - Returns: 성공여부를 반환합니다.
    func copy(at path: String, fileName name: String, to newPath: String) async -> Result<Void, MHDataError>
    
    /// 지정된 경로의 파일을 이동합니다.
    /// - Parameters:
    ///   - path: Documents/{path} 이런식으로 들어갑니다
    ///   - name: Documents/{path}/{name} 이 파일을 이동합니다. (확장자 명시 필요)
    ///   - newPath: Documents/{newPath}/{name} 으로  이동합니다.
    /// - Returns: 성공여부를 반환합니다.
    func move(at path: String, fileName name: String, to newPath: String) async -> Result<Void, MHDataError>
    
    /// 지정된 경로의 모든 파일을 이동합니다.
    /// - Parameters:
    ///   - path: Documents/{path} 이런식으로 들어갑니다
    ///   - newPath: Documents/{newPath} 으로  이동합니다.
    /// - Returns: 성공여부를 반환합니다.
    func moveAll(in path: String, to newPath: String) async -> Result<Void, MHDataError>
    
    /// 지정된 경로의 로컬 파일 URL을 반환합니다.
    /// Documents폴더기준으로 파일 URL을 반환합니다.
    /// - Parameters:
    ///   - path: Documents/{path} 이런식으로 들어갑니다
    ///   - name: Documents/{path}/{name} 이 파일 URL을 반환합니다. (확장자 명시 필요)
    /// - Returns: 파일 URL을 반환합니다.
    func getURL(at path: String, fileName name: String) async -> Result<URL, MHDataError>
}
