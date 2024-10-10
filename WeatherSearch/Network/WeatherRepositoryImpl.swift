//
//  WeatherRepositoryImpl.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/10/24.
//

import Foundation
import RxSwift

protocol WeatherRepository {
    func getWeatherData(for city: SearchCity) -> Single<WeatherModel>
}

final class WeatherRepositoryImpl: WeatherRepository {
    
    private let weatherService: WeatherAPIService

       init(weatherService: WeatherAPIService) {
           self.weatherService = weatherService
       }
    
    
    func getWeatherData(for city: SearchCity) -> Single<WeatherModel> {
        return weatherService.fetchWeather(for: city)
    }
}
