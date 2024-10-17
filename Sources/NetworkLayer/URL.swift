//
//  File.swift
//  NetworkLayer
//
//  Created by Feyyaz ONUR on 9.10.2024.
//

import Foundation

public extension URL {
    init(validating value: String) throws {
        if #available(iOS 17.0, *) {
            guard let url = URL(string: value, encodingInvalidCharacters: false) else {
                throw NetworkError.invalidURL
            }
            self = url
        } else {
            guard let url = URL(string: value) else {
                throw NetworkError.invalidURL
            }
            self = url
        }
    }
}
