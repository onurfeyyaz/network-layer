//
//  File.swift
//  NetworkLayer
//
//  Created by Feyyaz ONUR on 17.09.2024.
//

import Foundation
import NetworkLayer

enum MockEndpoint {
    case invalidURL
    case noData
    case getMethod
    case postMethod
}

extension MockEndpoint: Endpoint {
    var baseURL: URL {
        get throws {
            switch self {
            case .invalidURL:
                // This will throw if the URL is invalid
                try URL(validating: "http://exa mple.com")
            case .postMethod, .getMethod, .noData:
                URL(string: "https://example.com")!
            }
        }
    }
    
    var path: String {
        switch self {
        case .invalidURL:
            ""
        case .getMethod, .postMethod, .noData:
            "/mock/testing"
        }
    }
    
    var method: NetworkLayer.HTTPMethod {
        switch self {
        case .getMethod, .invalidURL, .noData:
                .GET
        case .postMethod:
                .POST
        }
    }
    
    var headers: [String : String]? {
        [
            "accept": "application/json",
            "Authorization": "Bearer swifttesting123"
        ]
    }
    
    var queryParameters: [String : CustomStringConvertible]? {
        return [
            "language": "tr-TR"
        ]
    }
    
    var body: Data? {
        return switch self {
        case .postMethod:
            """
            {
                "description": "This is a POST method"
            }
            """.data(using: .utf8)!
        case .getMethod, .invalidURL, .noData:
            nil
        }
    }
}
