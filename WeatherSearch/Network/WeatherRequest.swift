//
//  WeatherRequest.swift
//  YourWeather
//
//  Created by 이은호 on 10/4/24.
//

import Foundation
import Alamofire


enum WeatherRequest: WeatherAPIURLConvertible {
    case city
    
    var path: String {
        switch self {
        case .city:
            return ""
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .city: return .get
            
        }
    }
    
    var encoder: ParameterEncoding {
        switch self {
        case .city:
            return URLEncoding.default
        }
    }
    
    var parameters: Parameters? {
        return [:]
    }
}
