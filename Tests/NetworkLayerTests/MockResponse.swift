//
//  MockResponse.swift
//  NetworkLayer
//
//  Created by Feyyaz ONUR on 18.09.2024.
//

import Foundation

struct MockSuccessResponse: Decodable {
    let id: Int
    let name: String
}

struct MockErrorResponse: Decodable {
    let statusCode: Int
}

struct MockDecodingErrorResponse: Decodable {
    let temperature: Int
    let temperatureUnit: String
    
}

enum MockCodingKeys: String, CodingKey {
    case key
}
