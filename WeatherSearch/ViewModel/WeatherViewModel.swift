//
//  WeatherViewModel.swift
//  YourWeather
//
//  Created by 이은호 on 10/5/24.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

protocol WeatherService {
    func fetchWeather()
}

class WeatherViewModel {
    private let weatherService: WeatherService
    
    
    init(weatherService: WeatherService) {
        self.weatherService = weatherService
    }
    
    
    
}
