//
//  URLSession.swift
//  NetworkLayer
//
//  Created by Feyyaz ONUR on 17.09.2024.
//

import Foundation

/// A protocol to allow mocking of URLSession for testing purposes.
/// Conforms to Sendable for thread safety in async contexts.
public protocol URLSessionProtocol: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}
