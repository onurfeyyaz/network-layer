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
    
    public func request<T: Decodable, E: Decodable>(_ endpoint: Endpoint, responseType: T.Type, serverErrorType: E.Type) async -> Result<T, NetworkError> {
        guard let request = endpoint.urlRequest else {
            return .failure(NetworkError.invalidURL)
        }
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            let validationResult = validate(response: response, data: data, serverErrorType: serverErrorType)
            
            switch validationResult {
            case .success:
                return decode(data: data, to: responseType)
            case .failure(let error):
                return .failure(error)
            }
        } catch {
            return .failure(NetworkError.unknown(error))
        }
    }
    
    private func validate<T: Decodable>(response: URLResponse, data: Data, serverErrorType: T.Type) -> Result<Void, NetworkError> {
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(NetworkError.noData)
        }
        
        switch httpResponse.statusCode {
        case NetworkConstants.informationCodes:
            return .failure(NetworkError.informational(statusCode: httpResponse.statusCode, data: data))
        case NetworkConstants.successCodes:
            return .success(())
        case NetworkConstants.redirectionCodes:
            return .failure(NetworkError.redirection(statusCode: httpResponse.statusCode, data: data))
        case NetworkConstants.clientErrorCodes:
            return .failure(NetworkError.clientError(statusCode: httpResponse.statusCode, data: data))
        case NetworkConstants.serverErrorCodes:
            return decodeServerError(data: data, statusCode: httpResponse.statusCode, serverErrorType: serverErrorType)
        default:
            return .failure(NetworkError.unexpectedStatusCode(statusCode: httpResponse.statusCode, data: data))
        }
    }
    
    
    private func decode<T: Decodable>(data: Data, to type: T.Type) -> Result<T, NetworkError> {
        do {
            let decodedValue = try decoder.decode(T.self, from: data)
            return .success(decodedValue)
        } catch {
            return .failure(NetworkError.decodingError(error))
        }
    }
    
    private func decodeServerError<T: Decodable>(data: Data, statusCode: Int, serverErrorType: T.Type) -> Result<Void, NetworkError> {
        do {
            let serverError = try decoder.decode(T.self, from: data)
            let errorMessage = "Server Error \(statusCode): \(serverError)"
            return .failure(NetworkError.serverError(statusCode: statusCode, data: data, message: errorMessage))
        } catch {
            return .failure(NetworkError.serverError(statusCode: statusCode, data: data, message: "An unknown server error occurred."))
        }
    }
    
}
