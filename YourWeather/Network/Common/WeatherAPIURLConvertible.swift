//
//  WeatherAPIURLConvertible.swift
//  YourWeather
//
//  Created by 이은호 on 10/4/24.
//

import Foundation
import Alamofire

public typealias HTTPMethod = Alamofire.HTTPMethod
public typealias Parameters = Alamofire.Parameters
public typealias HTTPHeaders = Alamofire.HTTPHeaders
public typealias ParameterEncoding = Alamofire.ParameterEncoding

public protocol BaseAPIURLConvertable {
                                
    var basePath: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var encoder: ParameterEncoding { get }
    var header: HTTPHeaders? { get }
}

public extension BaseAPIURLConvertable {
    var method: HTTPMethod { .get }
    var parameters: Parameters? { nil }
    var encoder: ParameterEncoding { URLEncoding.default }
    var header: HTTPHeaders? { .default }
}

extension BaseAPIURLConvertable {
    
    var urlString: String { basePath.appending(path) }
    
    func asDataRequset() -> DataRequest {
        AF.request(
            urlString,
            method: method,
            parameters: parameters,
            encoding: encoder,
            headers: header
        )
        .validate()
    }
}


protocol WeatherAPIURLConvertible: BaseAPIURLConvertable {}

extension WeatherAPIURLConvertible {
    var basePath: String { "" }
    
    var header: HTTPHeaders? {
        [
            .contentType("application/json-patch+json")
        ]
    }
}
