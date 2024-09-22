//
//  NetworkManager.swift
//  NetworkLayer
//
//  Created by Feyyaz ONUR on 1.09.2024.
//

import Foundation

fileprivate enum NetworkConstants {
    static let informationCodes = 100...199
    static let successCodes = 200...299
    static let redirectionCodes = 300...399
    static let clientErrorCodes = 400...499
    static let serverErrorCodes = 500...599
}

public actor NetworkManager {
    
    public static let shared = NetworkManager()
    private let urlSession: URLSessionProtocol
    private let decoder: JSONDecoder
    
    init(urlSession: URLSessionProtocol = URLSession.shared, decoder: JSONDecoder = JSONDecoder()) {
        self.urlSession = urlSession
        self.decoder = decoder
    }
    
    public func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type) async throws -> T {
        guard let request = endpoint.urlRequest else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            try validate(response: response, data: data)
            
            return try decode(data: data, to: responseType)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        switch httpResponse.statusCode {
        case NetworkConstants.informationCodes:
            throw NetworkError.informational(statusCode: httpResponse.statusCode, data: data)
        case NetworkConstants.successCodes:
            return
        case NetworkConstants.redirectionCodes:
            throw NetworkError.redirection(statusCode: httpResponse.statusCode, data: data)
        case NetworkConstants.clientErrorCodes:
            throw NetworkError.clientError(statusCode: httpResponse.statusCode, data: data)
        case NetworkConstants.serverErrorCodes:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, data: data)
        default:
            throw NetworkError.unexpectedStatusCode(statusCode: httpResponse.statusCode, data: data)
        }
    }
    
    private func decode<T: Decodable>(data: Data, to type: T.Type) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
