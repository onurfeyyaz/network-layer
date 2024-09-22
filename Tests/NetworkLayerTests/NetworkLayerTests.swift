import Testing
import Foundation
@testable import NetworkLayer

@Suite("Endpoint Tests")
struct EndpointCheck {
    let mockEndpoint = MockEndpoint()
    
    @Test("Base URL and path are valid") func baseURLandPath() async throws {
        try #require(mockEndpoint.urlRequest?.url != nil)
        #expect(mockEndpoint.urlRequest?.url!.absoluteString.contains("https://example.com/mock/testing") ?? false)
    }
    
    @Test("HTTP method is GET") func httpMethod() {
        #expect(mockEndpoint.urlRequest?.httpMethod?.contains("GET") ?? false)
    }
    
    @Test("Header fields have an Authorization") func httpHeaderFields() {
        #expect((mockEndpoint.urlRequest?.allHTTPHeaderFields?["Authorization"]?.contains("Bearer swifttesting123")) ?? false)
    }
    
    @Test("Query parameter has a language value") func queryParams() {
        #expect(mockEndpoint.queryParameters?["language"] as? String == "tr-TR")
    }
    
    @Test("HTTP body is nil") func httpBody() {
        #expect(mockEndpoint.urlRequest?.httpBody == nil)
    }
}

@Suite("Network Manager Tests")
struct NetworkManagerTest {
    let mockURLSession = MockURLSession()
    
    @Test("Response Errors Tests", arguments: [
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
        let endpoint = MockEndpoint()
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
    
    @Test("Successful Request Test") func successfulRequest() async throws {
        let endpoint = MockEndpoint()
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
}
