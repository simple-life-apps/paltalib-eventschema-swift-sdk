//
//  HTTPClientMock.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 07.04.2022.
//

import Foundation
import PaltaCore

final class HTTPClientMock: HTTPClient {
    var request: HTTPRequest?
    
    var urlRequest: URLRequest?
    var response: (HTTPURLResponse?, Data?)?
    var result: Result<Any, Error>?
    
    var mandatoryHeaders: [String : String] = [:]

    func perform<SuccessResponse: Decodable, ErrorResponse: Decodable>(
        _ request: HTTPRequest,
        with completion: @escaping (Result<SuccessResponse, NetworkErrorWithResponse<ErrorResponse>>) -> Void
    ) {
        perform(request, requestMiddleware: { _ in }, responseMiddleware: { _, _ in }, with: completion)
    }
    
    func perform<SuccessResponse: Decodable, ErrorResponse: Decodable>(
        _ request: HTTPRequest,
        requestMiddleware: @escaping (URLRequest) -> Void,
        responseMiddleware: @escaping (HTTPURLResponse?, Data?) -> Void,
        with completion: @escaping (Result<SuccessResponse, NetworkErrorWithResponse<ErrorResponse>>) -> Void
    ) {
        self.request = request
        
        if let urlRequest = urlRequest {
            requestMiddleware(urlRequest)
        }
        
        if let response = response {
            responseMiddleware(response.0, response.1)
        }

        completion(
            result?
                .map { $0 as! SuccessResponse }
                .mapError { $0 as! NetworkErrorWithResponse<ErrorResponse> }
            ?? .failure(.noData)
        )
    }
}
