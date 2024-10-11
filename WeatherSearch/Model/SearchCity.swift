//
//  SearchCity.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/6/24.
//

import Foundation

struct SearchCity: Codable, Equatable {
    var id: Int
    var cityName: String?
    var country: String?
    var appid: String
    var lat: String
    var lon: String
    var units: String
    
    init(id: Int, cityName: String?, country: String?,lat: String, lon: String) {
        self.id = id
        self.cityName = cityName
        self.country = country
        self.appid = WeatherAPIService.getApiKey()
        self.lat = lat
        self.lon = lon
        self.units = "metric"
    }
}
