//
//  NetworkError.swift
//  NetworkLayer
//
//  Created by Feyyaz ONUR on 1.09.2024.
//
import Foundation

public enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case redirection(statusCode: Int, data: Data)
    case clientError(statusCode: Int, data: Data)
    case serverError(statusCode: Int, data: Data)
    case unexpectedStatusCode(statusCode: Int, data: Data)
    case unknown(Error)
}
