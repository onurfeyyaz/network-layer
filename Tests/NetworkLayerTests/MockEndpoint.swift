//
//  File.swift
//  NetworkLayer
//
//  Created by Feyyaz ONUR on 17.09.2024.
//

import Foundation
import NetworkLayer

struct MockEndpoint: Endpoint {
    var baseURL: URL {
        URL(string: "https://example.com")!
    }
    
    var path: String {
        "/mock/testing"
    }
    
    var method: NetworkLayer.HTTPMethod {
        .GET
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
        return nil
    }
}
