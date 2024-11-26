import Testing
@testable import MHData
@testable import MHFoundation

@Suite("Serial model tests", .serialized) final class MHFileManagerTests {
    private var fileManager: MHFileManager!
    private let testDirectory = "TestDirectory"
    private let newTestDirectory = "NewTestDirectory"
    private let testFileName = "testFile.txt"
    private let testFileData = "Hello, File!".data(using: .utf8)!
    
    init() {
        self.fileManager = MHFileManager(directoryType: .documentDirectory)
    }
    
    @Test func test파일생성_성공() async {
        // Arrange
        let path = testDirectory
        
        // Act
        let result = await fileManager.create(at: path, fileName: testFileName, data: testFileData)
        
        // Assert
        switch result {
        case .success:
            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = directoryURL.appendingPathComponent(path).appendingPathComponent(testFileName)
            #expect(FileManager.default.fileExists(atPath: fileURL.path))
        case .failure(let error):
            #expect(false, "\(#function) 실패함: \(error)")
        }
    }
    @Test func test파일읽기_성공() async {
        // Arrange
        let path = testDirectory
        _ = await fileManager.create(at: path, fileName: testFileName, data: testFileData)
        
        // Act
        let result = await fileManager.read(at: path, fileName: testFileName)
        
        // Assert
        switch result {
        case .success(let data):
            #expect(data == testFileData)
        case .failure(let error):
            #expect(false, "\(#function) 실패함: \(error)")
        }
    }
    @Test func test없는_파일읽기_실패() async {
        // Arrange
        let path = testDirectory
        
        // Act
        let result = await fileManager.read(at: path, fileName: "nonExistentFile.txt")
        
        // Assert
        switch result {
        case .success:
            #expect(false, "\(#function) 실패해야하는데 성공함")
        case .failure(let error):
            #expect(error == .fileReadingFailure)
        }
    }
    @Test func test파일삭제_성공() async {
        // Arrange
        let path = testDirectory
        _ = await fileManager.create(at: path, fileName: testFileName, data: testFileData)
        
        // Act
        let result = await fileManager.delete(at: path, fileName: testFileName)
        
        // Assert
        switch result {
        case .success:
            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = directoryURL.appendingPathComponent(path).appendingPathComponent(testFileName)
            #expect(!FileManager.default.fileExists(atPath: fileURL.path))
        case .failure(let error):
            #expect(false, "\(#function) 실패함: \(error)")
        }
    }
    @Test func test없는_파일삭제_실패() async {
        // Arrange
        let path = testDirectory
        
        // Act
        let result = await fileManager.delete(at: path, fileName: testFileName)
        
        // Assert
        switch result {
        case .success:
            #expect(false, "\(#function) 실패해야하는데 성공함")
        case .failure(let error):
            #expect(error == .fileDeletionFailure)
        }
    }
    @Test func test파일이동_성공() async {
        // Arrange
        let path = testDirectory
        _ = await fileManager.create(at: path, fileName: testFileName, data: testFileData)
        
        // Act
        let newPath = newTestDirectory
        let result = await fileManager.move(at: path, fileName: testFileName, to: newPath)
        
        // Assert
        switch result {
        case .success:
            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let newFileURL = directoryURL.appendingPathComponent(newPath).appendingPathComponent(testFileName)
            #expect(FileManager.default.fileExists(atPath: newFileURL.path))
        case .failure(let error):
            #expect(false, "\(#function) 실패함: \(error)")
        }
    }

    
    deinit {
        // 테스트 디렉토리와 관련된 파일 정리
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let testDirectoryURL = directoryURL.appendingPathComponent(testDirectory)
        let newTestDirectoryURL = directoryURL.appendingPathComponent(newTestDirectory)
        
        if FileManager.default.fileExists(atPath: testDirectoryURL.path) {
            try? FileManager.default.removeItem(at: testDirectoryURL)
        }
        if FileManager.default.fileExists(atPath: newTestDirectoryURL.path) {
            try? FileManager.default.removeItem(at: newTestDirectoryURL)
        }
    }
}
