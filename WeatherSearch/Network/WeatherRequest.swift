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
    case weekdaysCity(data: SearchCity)
    case weekdaysLatLon(data: SearchCity)
    
    var path: String {
        switch self {
        case .cityName, .latlon:
            return "/forecast"
        case .weekdaysCity, .weekdaysLatLon:
            return "/forecast"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .cityName, .latlon, .weekdaysCity, .weekdaysLatLon: return .get
            
        }
    }
    
    var encoder: ParameterEncoding {
        switch self {
        case .cityName, .latlon, .weekdaysCity, .weekdaysLatLon:
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
                    "cnt" : 7
            ]
            
            
        case .latlon(let info):
            return ["lat":info.lat!,
                    "lon":info.lon!,
                    "appid":info.appid,
                    "units": info.units,
                    "lang":"kr",
                    "cnt" : 7
            ]
        case .weekdaysCity(let info):
            return ["q": info.cityName!,
                    "appid":info.appid,
                    "units": info.units,
                    "lang":"kr",
                    "cnt" : 7
            ]
        case .weekdaysLatLon(let info):
            return ["lat":info.lat!,
                    "lon":info.lon!,
                    "appid":info.appid,
                    "units": info.units,
                    "lang":"kr",
                    "cnt" : 7
            ]
        }
    }
}
