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
    case getMethod
    case postMethod
}

extension MockEndpoint: Endpoint {
    var baseURL: URL {
        switch self {
        case .invalidURL:
            URL(string: "invalidURLText")!
        case .postMethod, .getMethod:
            URL(string: "https://example.com")!
        }
    }
    
    var path: String {
        "/mock/testing"
    }
    
    var method: NetworkLayer.HTTPMethod {
        switch self {
        case .getMethod, .invalidURL:
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
        case .getMethod, .invalidURL:
            nil
        }
    }
}
