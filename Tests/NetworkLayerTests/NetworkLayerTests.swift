import Testing
@testable import NetworkLayer

@Suite("Endpoint Tests")
struct EndpointCheck {
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
