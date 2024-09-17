import Testing
import Foundation
@testable import NetworkLayer

@Suite("Endpoint Tests")
struct endpointCheck {
    let mockEndpoint = MockEndpoint()

    @Test("Base URL and path are valid") func baseURLandPath() {
        #expect(mockEndpoint.urlRequest!.url!.absoluteString.contains("https://example.com/mock/testing"))
    }
    
    @Test("HTTP method is GET") func httpMethod() {
        #expect(mockEndpoint.urlRequest!.httpMethod!.contains("GET"))
    }
    
    @Test("Header fields have an Authorization") func httpHeaderFields() {
        #expect((mockEndpoint.urlRequest!.allHTTPHeaderFields!["Authorization"]?.contains("Bearer swifttesting123"))!)
    }
    
    @Test("Query parameter has a language value") func queryParams() {
        #expect(mockEndpoint.queryParameters!["language"] as! String == "tr-TR")
    }
    
    @Test("HTTP body is nil") func httpBody() {
        #expect(mockEndpoint.urlRequest?.httpBody == nil)
    }
}

@Suite("Network Manager test")
struct networkManagerRequestTest {
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLSession.self]
        return URLSession(configuration: configuration)
    }()
    
    lazy var networkManager: NetworkManager = {
        NetworkManager(urlSession: session)
    }()
    
    @Test("Request test") func reqTest() async throws {
    }
}
