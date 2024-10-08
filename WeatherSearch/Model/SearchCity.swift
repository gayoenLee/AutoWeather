//
//  SearchCity.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/6/24.
//

import Foundation

struct SearchCity: Codable, Equatable {
    var cityName: String?
    var appid: String
    var lat: String?
    var lon: String?
    var units: String
    
    init(cityName: String?, lat: String?, lon: String?) {
        self.cityName = cityName
        self.appid = WeatherAPIService.getApiKey()
        self.lat = lat
        self.lon = lon
        self.units = "metric"
    }
}
