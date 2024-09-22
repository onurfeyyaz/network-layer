//
//  MockURLSession.swift
//  NetworkLayer
//
//  Created by Feyyaz ONUR on 17.09.2024.
//

import Foundation
import NetworkLayer

actor MockURLSession {
    private var mockDataTask: (Data, URLResponse)?
    
    func setMockDataTask(data: Data, response: URLResponse) {
        self.mockDataTask = (data, response)
    }
}

extension MockURLSession: URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        guard let mockDataTask = self.mockDataTask else {
            throw NetworkError.noData
        }
        
        return mockDataTask
    }
}
