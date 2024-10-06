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
import UIKit

protocol WeatherService {
    func fetchWeather()
}

final class WeatherViewModel {
    private let weatherService: WeatherService
    var sections : WeatherCollectionViewCellType
    init(weatherService: WeatherService, sections: WeatherCollectionViewCellType) {
        self.weatherService = weatherService
        self.sections = sections
    }
    
    
    enum WeatherCollectionViewCellType {
        case today
        case twoDays
        case fiveDays
        case location
        case humidityWithCloud
        case WindSpeed
        
        func getCellTypeDescription() -> String {
                  switch self {
                  case .today:
                      return "CityTodayInfoCell"
                  case .twoDays:
                      return "HourlyWeatherCell"
                  case .fiveDays:
                      return "FiveDayInfoCell"
                  case .location:
                      return "CurrentLocationCell"
                  case .humidityWithCloud:
                      return "HumidityWithCloudCell"
                  case .WindSpeed:
                      return"HumidityWithCloudCell"
                  }
              }
              
//              // 각 케이스에 맞는 셀 높이 설정 등 다른 함수도 추가 가능
//              func getCellHeight() -> CGFloat {
//                  switch self {
//                  case .today:
//                      return 200.0
//                  case .twoDays:
//                      return 150.0
//                  case .fiveDays:
//                      return 180.0
//                  case .location:
//                      return 250.0
//                  case .humidityWithCloud, .windSpeed:
//                      return 100.0
//                  }
    }
}
