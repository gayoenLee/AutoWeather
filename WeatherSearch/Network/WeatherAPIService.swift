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
        print("api key찾는중")
        guard let weatherKey = Bundle.main.object(forInfoDictionaryKey: "WeatherAPIKey") as? String else {
            print("Not found WeatherAPI Key")
            return ""
        }
        print("api key리턴함: \(weatherKey)")
        return weatherKey
    }
    
    
    
    func fetchWeather(for city: SearchCity) -> Single<WeatherModel>  {
        let request : WeatherRequest
        
        if let name = city.cityName{
            request = .cityName(data: city)
        }else{
            request = .latlon(data: city)
        }
        print("featch weather: \(request.parameters)")
            let client = APIClient<WeatherRequest, WeatherModel>(request: request)
        print("featch weather: \(client.request.urlString)")
        print("featch ")

        client.request.urlString
            return client.requestData()
        }
        
    }
