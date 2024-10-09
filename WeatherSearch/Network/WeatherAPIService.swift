//
//  WeatherService.swift
//  YourWeather
//
//  Created by 이은호 on 10/4/24.
//

import Foundation
import Alamofire
import RxSwift

protocol WeatherService {
    func fetchWeather(for city: SearchCity) -> Single<WeatherModel>
}

final class WeatherAPIService: WeatherService {
    
    static func getApiKey()-> String {
        guard let weatherKey = Bundle.main.object(forInfoDictionaryKey: "WeatherAPIKey") as? String else {
            print("Not found WeatherAPI Key")
            return ""
        }
        return weatherKey
    }
    
    
    
    func fetchWeather(for city: SearchCity) -> Single<WeatherModel>  {
        let request : WeatherRequest
        
        if city.cityName == nil{
            request = .cityName(data: city)
        }else{
            request = .latlon(data: city)
        }
        print("featch weather: \(String(describing: request.parameters))")
            let client = APIClient<WeatherRequest, WeatherModel>(request: request)

            return client.requestData()
        }
        
    }
