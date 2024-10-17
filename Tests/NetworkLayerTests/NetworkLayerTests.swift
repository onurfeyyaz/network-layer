import Testing
import Foundation
@testable import NetworkLayer

@Suite("Endpoint Tests")
struct EndpointCheck {
    let mockGetEndpoint = MockEndpoint.getMethod
    let mockPostEndpoint = MockEndpoint.postMethod
    
    @Test("Base URL and path are valid") func baseURLandPath() async throws {
        try #require(mockGetEndpoint.urlRequest?.url != nil)
        #expect(mockGetEndpoint.urlRequest?.url!.absoluteString.contains("https://example.com/mock/testing") ?? false)
    }
    
    @Test("HTTP method is GET") func getHttpMethod() {
        #expect(mockGetEndpoint.urlRequest?.httpMethod?.contains("GET") ?? false)
    }
    
    @Test("HTTP method is POST") func postHttpMethod() {
        #expect(mockPostEndpoint.urlRequest?.httpMethod?.contains("POST") ?? false)
    }
    
    @Test("Header fields have an Authorization") func httpHeaderFields() {
        #expect((mockGetEndpoint.urlRequest?.allHTTPHeaderFields?["Authorization"]?.contains("Bearer swifttesting123")) ?? false)
    }
    
    @Test("Query parameter has a language value") func queryParams() {
        #expect(mockGetEndpoint.queryParameters?["language"] as? String == "tr-TR")
    }
    
    @Test("GET body is nil") func getHttpBody() {
        #expect(mockGetEndpoint.urlRequest?.httpBody == nil)
    }
    
    @Test("POST body is not nil") func postHttpBody() {
        let expectedBody = """
        {
            "description": "This is a POST method"
        }
        """.data(using: .utf8)
        #expect(mockPostEndpoint.urlRequest?.httpBody == expectedBody)
    }
}

@Suite("Network Manager Tests")
struct NetworkManagerTest {
    let mockURLSession = MockURLSession()
    
    @Test("Successful Request Test") func successfulRequest() async throws {
        let endpoint = MockEndpoint.getMethod
        let mockJsonData = """
        {
            "id": 1,
            "name": "Swift Testing"
        }
        """.data(using: .utf8)!
        
        let mockSuccessResponse = HTTPURLResponse(url: URL(string: "https://example.com")!,
                                                  statusCode: 200,
                                                  httpVersion: nil,
                                                  headerFields: nil)!

        await mockURLSession.setMockDataTask(data: mockJsonData, response: mockSuccessResponse)
        let networkManager = NetworkManager(urlSession: mockURLSession)
        
        // No error thrown because the response is successful
        let result = try await networkManager.request(endpoint, responseType: MockSuccessResponse.self)
        
        #expect(result.id == 1)
        #expect(result.name.contains("Swift Testing"))
    }
    
    @Test("Response Errors Tests", arguments: [
        HTTPURLResponse(url: URL(string: "https://example.com")!,
                        statusCode: 100,
                        httpVersion: nil,
                        headerFields: nil)!,
        HTTPURLResponse(url: URL(string: "https://example.com")!,
                        statusCode: 300,
                        httpVersion: nil,
                        headerFields: nil)!,
        HTTPURLResponse(url: URL(string: "https://example.com")!,
                        statusCode: 400,
                        httpVersion: nil,
                        headerFields: nil)!,
        HTTPURLResponse(url: URL(string: "https://example.com")!,
                        statusCode: 500,
                        httpVersion: nil,
                        headerFields: nil)!,
        HTTPURLResponse(url: URL(string: "https://example.com")!,
                        statusCode: 678,
                        httpVersion: nil,
                        headerFields: nil)!
    ])
    func responseErrors(response: HTTPURLResponse) async throws {
        let endpoint = MockEndpoint.getMethod
        let mockJsonData = """
        {
            "statusCode": \(response.statusCode)
        }
        """.data(using: .utf8)!
        
        await mockURLSession.setMockDataTask(data: mockJsonData, response: response)
        let networkManager = NetworkManager(urlSession: mockURLSession)
        
        // Expecting an error; test passes if error is thrown
        await #expect(throws: NetworkError.self) {
            try await networkManager.request(endpoint, responseType: MockErrorResponse.self)
        }
    }
    
    
    @Test("Invalid URL") func invalidURL() async throws {
     // need to mock endpoint with a nil URLRequest
     
        let endpoint = MockEndpoint.invalidURL
        let response = HTTPURLResponse(url: URL(string: "http://example.com")!,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)!
        let mockData = """
        {
            "statusCode": 22
        }
        """.data(using: .utf8)!
        
        await mockURLSession.setMockDataTask(data: mockData, response: response)
        let networkManager = NetworkManager(urlSession: mockURLSession)
        
        await #expect(throws: NetworkError.invalidURL.self) {
            try await networkManager.request(endpoint, responseType: MockErrorResponse.self)
        
        }
    }
    
    @Test("No Response Data") func noResponseData() async throws {
        let endpoint = MockEndpoint.noData
        let networkManager = NetworkManager(urlSession: mockURLSession)
        
        await #expect(throws: NetworkError.noData.self) {
            try await networkManager.request(endpoint, responseType: MockErrorResponse.self)
        }
    }
    
    @Suite("Decoding Errors")
    struct DecodingErrors {
        let mockURLSession = MockURLSession()
        let endpoint = MockEndpoint.getMethod
        
        let response = HTTPURLResponse(url: URL(string: "http://example.com")!,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)!
        
        let dataCorruptedError = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Mock corrupted data"))
        let mockCorruptedData = """
        {
            "temperature" = 22
            "temperatureUnit" = "Celsius
        }
        """.data(using: .utf8)!
        
        let keyNotFoundError = DecodingError.keyNotFound(MockCodingKeys.key, .init(codingPath: [], debugDescription: "Key not found"))
        let mockKeyNotFoundData = """
        {
            "code": 22,
            "temperatureUnit": "Celsius",
        }
        """.data(using: .utf8)!
        
        let typeMismatchError = DecodingError.typeMismatch(Int.self, .init(codingPath: [], debugDescription: "Type mismatch"))
        let mockTypeMismatchData = """
        {
            "temperature": "22",
            "temperatureUnit": "Celsius",
        }
        """.data(using: .utf8)!
        
        let valueNotFoundError = DecodingError.valueNotFound(Int.self, .init(codingPath: [], debugDescription: "Value not found"))
        let mockValueNotFoundData = """
        {
            "temperature": null,
            "temperatureUnit": "Celsius",
        }
        """.data(using: .utf8)!
        
        @Test("Data Corrupted Error") func dataCorrupted() async throws {
            await mockURLSession.setMockDataTask(data: mockCorruptedData, response: response)
            let networkManager = NetworkManager(urlSession: mockURLSession)
            
            await #expect(throws: NetworkError.decodingError(dataCorruptedError).self) {
                try await networkManager.request(endpoint, responseType: MockDecodingErrorResponse.self)
            }
        }
        
        @Test("Key not Found Error") func keyNotFound() async throws {
            await mockURLSession.setMockDataTask(data: mockKeyNotFoundData, response: response)
            let networkManager = NetworkManager(urlSession: mockURLSession)
            
            await #expect(throws: NetworkError.decodingError(keyNotFoundError).self) {
                try await networkManager.request(endpoint, responseType: MockDecodingErrorResponse.self)
            }
        }
        
        @Test("Type Mismatch Error") func typeMismatch() async throws {
            await mockURLSession.setMockDataTask(data: mockTypeMismatchData, response: response)
            let networkManager = NetworkManager(urlSession: mockURLSession)
            
            await #expect(throws: NetworkError.decodingError(typeMismatchError).self) {
                try await networkManager.request(endpoint, responseType: MockDecodingErrorResponse.self)
            }
        }
        
        @Test("Value not Found Error") func valueNotFound() async throws {
            await mockURLSession.setMockDataTask(data: mockValueNotFoundData, response: response)
            let networkManager = NetworkManager(urlSession: mockURLSession)
            
            await #expect(throws: NetworkError.decodingError(valueNotFoundError).self) {
                try await networkManager.request(endpoint, responseType: MockDecodingErrorResponse.self)
            }
        }
    }
}
