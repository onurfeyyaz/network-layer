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
}
