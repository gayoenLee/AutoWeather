//
//  APIClient.swift
//  YourWeather
//
//  Created by 이은호 on 10/4/24.
//

import Foundation
import Alamofire

public typealias APIClientError = AFError

public struct APIClient<Request: BaseAPIURLConvertable, Response: Decodable> {
    private let request: Request
    
    public init(request: Request) {
        self.request = request
    }
    
    public func request() async -> Result<Response, APIClientError>  {
        await request.asDataRequset()
            .serializingDecodable(Response.self)
            .response
            .result
    }
    
    public func requestData() async -> Result<Data, APIClientError> {
        await request.asDataRequset()
            .serializingData()
            .response
            .result
    }
}

public struct VoidResponse: Decodable {
    
}
