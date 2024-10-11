//
//  WeatherRequest.swift
//  YourWeather
//
//  Created by 이은호 on 10/4/24.
//

import Foundation
import Alamofire


enum WeatherRequest: WeatherAPIURLConvertible {
    case cityInfoToShow(data: SearchCity)
    
    var path: String {
        switch self {
        case .cityInfoToShow:
            return "/forecast"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .cityInfoToShow:
            return .get
            
        }
    }
    
    var encoder: ParameterEncoding {
        switch self {
        case .cityInfoToShow:
            return URLEncoding.default
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .cityInfoToShow(let info):
            return ["lat": info.lat,
                    "lon": info.lon,
                    "appid":info.appid,
                    "units": info.units,
                    "lang":"kr",
                    "cnt" : 35
            ]
        }
    }
}
