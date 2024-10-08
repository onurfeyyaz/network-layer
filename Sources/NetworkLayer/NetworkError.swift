//
//  NetworkError.swift
//  NetworkLayer
//
//  Created by Feyyaz ONUR on 1.09.2024.
//

import Foundation

/// Represents errors that can occur during network operations.
public enum NetworkError: Error, Equatable {
    /// Indicates that the provided URL is invalid.
    case invalidURL
    
    /// Indicates that no data was received from the server.
    case noData
    
    /// Indicates a decoding error occurred while processing the response.
    case decodingError(Error)
    
    /// Indicates an informational (100 to 199) response with a status code.
    /// - Parameters:
    ///   - statusCode: The status code received from the server.
    ///   - data: The data associated with the informational response.
    case informational(statusCode: Int, data: Data)
    
    /// Indicates a redirection (300 to 399) response with a status code.
    /// - Parameters:
    ///   - statusCode: The status code received from the server.
    ///   - data: The data associated with the redirection response.
    case redirection(statusCode: Int, data: Data)
    
    /// Indicates a client error (400 to 499) response with a status code.
    /// - Parameters:
    ///   - statusCode: The status code received from the server.
    ///   - data: The data associated with the client error response.
    case clientError(statusCode: Int, data: Data)
    
    /// Indicates a server error (500 to 599) response with a status code.
    /// - Parameters:
    ///   - statusCode: The status code received from the server.
    ///   - data: The data associated with the server error response.
    case serverError(statusCode: Int, data: Data)
    
    /// Indicates an unexpected status code was received.
    /// - Parameters:
    ///   - statusCode: The unexpected status code received from the server.
    ///   - data: The data associated with the unexpected status code.
    case unexpectedStatusCode(statusCode: Int, data: Data)
    
    /// Indicates an unknown error occurred.
    /// - Parameter error: The underlying error that occurred.
    case unknown(Error)
    
    private enum ErrorMessages {
        static let invalidURL = "[INVALID] The URL provided was invalid."
        static let noData = "[NODATA] No data was received from the server."
        static let decodingError = "[DECODE] Failed to decode the response."
        static let informational = "[INFORMATIONAL] Status code:"
        static let redirection = "[REDIRECTION] Status code:"
        static let clientError = "[CLIENT] Status code:"
        static let serverError = "[SERVER] Status code:"
        static let unexpectedStatusCode = "[UNEXPECTED] Status code:"
        static let unknownError = "[UNKNOWN] An unknown error occurred."
    }
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return ErrorMessages.invalidURL
        case .noData:
            return ErrorMessages.noData
        case .decodingError(let error):
            return "\(ErrorMessages.decodingError) Error: \(error.localizedDescription)"
        case .informational(let statusCode, let data):
            return "\(ErrorMessages.informational) \(statusCode). Response: \(self.dataToString(data))"
        case .redirection(let statusCode, let data):
            return "\(ErrorMessages.redirection) \(statusCode). Response: \(self.dataToString(data))"
        case .clientError(let statusCode, let data):
            return "\(ErrorMessages.clientError) \(statusCode). Response: \(self.dataToString(data))"
        case .serverError(let statusCode, let data):
            return "\(ErrorMessages.serverError) \(statusCode). Response: \(self.dataToString(data))"
        case .unexpectedStatusCode(let statusCode, let data):
            return "\(ErrorMessages.unexpectedStatusCode) \(statusCode). Response: \(self.dataToString(data))"
        case .unknown(let error):
            return "\(ErrorMessages.unknownError) Error: \(error.localizedDescription)"
        }
    }
    
    private func dataToString(_ data: Data) -> String {
        return String(data: data, encoding: .utf8) ?? "No readable data"
    }
    
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
            (.noData, .noData):
            return true
        case (.decodingError(let lhsError), .decodingError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.informational(let lhsStatusCode, let lhsData), .informational(let rhsStatusCode, let rhsData)),
            (.redirection(let lhsStatusCode, let lhsData), .redirection(let rhsStatusCode, let rhsData)),
            (.clientError(let lhsStatusCode, let lhsData), .clientError(let rhsStatusCode, let rhsData)),
            (.serverError(let lhsStatusCode, let lhsData), .serverError(let rhsStatusCode, let rhsData)),
            (.unexpectedStatusCode(let lhsStatusCode, let lhsData), .unexpectedStatusCode(let rhsStatusCode, let rhsData)):
            return lhsStatusCode == rhsStatusCode && lhsData == rhsData
        case (.unknown(let lhsError), .unknown(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
