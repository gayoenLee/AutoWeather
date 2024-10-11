//
//  WeatherRequest.swift
//  YourWeather
//
//  Created by 이은호 on 10/4/24.
//

import Foundation
import Alamofire


enum WeatherRequest: WeatherAPIURLConvertible {
    case cityName(data: SearchCity)
    case latlon(data: SearchCity)
    
    var path: String {
        switch self {
        case .cityName, .latlon:
            return "/forecast"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .cityName, .latlon:
            return .get
            
        }
    }
    
    var encoder: ParameterEncoding {
        switch self {
        case .cityName, .latlon:
            return URLEncoding.default
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .cityName(let info):
            return ["q": info.cityName!,
                    "appid":info.appid,
                    "units": info.units,
                    "lang":"kr",
                    "cnt" : 35
            ]
            
            
        case .latlon(let info):
            return ["lat":info.lat!,
                    "lon":info.lon!,
                    "appid":info.appid,
                    "units": info.units,
                    "lang":"kr",
                    "cnt" : 35
            ]
        }
    }
}
