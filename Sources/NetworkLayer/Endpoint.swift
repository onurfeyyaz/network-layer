//
//  Endpoint.swift
//  NetworkLayer
//
//  Created by Feyyaz ONUR on 1.09.2024.
//

import Foundation

public protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: CustomStringConvertible]? { get }
    var body: Data? { get }
}

extension Endpoint {
    public var urlRequest: URLRequest? {
        guard var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path),
                                                resolvingAgainstBaseURL: false) else { return nil }
        if let queryParameters {
            urlComponents.queryItems = queryParameters.map {
                URLQueryItem(name: $0.key, value: $0.value.description)
            }
        }
        
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        request.httpBody = body
        return request
    }
}
