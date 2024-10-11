//
//  WeatherService.swift
//  YourWeather
//
//  Created by 이은호 on 10/4/24.
//

import Foundation
import Alamofire
import RxSwift

protocol WeatherServiceProtocol {
    func fetchWeather(for city: SearchCity) -> Single<WeatherModel>
}

final class WeatherAPIService: WeatherServiceProtocol {
    
    static func getApiKey()-> String {
        guard let weatherKey = Bundle.main.object(forInfoDictionaryKey: "WeatherAPIKey") as? String else {
            fatalError("Weather API Key not found")
        }
        return weatherKey
    }
        
    func fetchWeather(for city: SearchCity) -> Single<WeatherModel>  {
        let request : WeatherRequest
        
            request = .cityInfoToShow(data: city)
            let client = APIClient<WeatherRequest, WeatherModel>(request: request)
            return client.requestData()
            .do(onSuccess: { weatherModel in
                }, onError: { error in
                    print("API 요청 중 에러 발생: \(error)")
                })
        }
        
    }
