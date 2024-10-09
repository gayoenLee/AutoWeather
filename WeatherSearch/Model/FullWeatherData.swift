//
//  FullWeatherData.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/9/24.
//

import Foundation

struct FullWeatherData {
    var todayCityInfo: TodayCityInfoData?
    var threeHourData: [ThreeHourWeatherData]?
    var dailyWeatherData: [DailyWeatherData]?
    var mapLocationData: MapLocationData?
    var averageData: AverageWeatherData?
    
}

struct ThreeHourWeatherData {
    var time: String
    var iconName: String
    var temperature: String
}
struct AverageWeatherData {
    var humidity: String
    var clouds: String
    var windSpeed: String
}

struct DailyWeatherData {
    var dayOfWeek: String
    var icon: String
    var tempMax: Double
    var tempMin: Double
}

struct MapLocationData{
    var lat: String
    var lon: String
}

struct TodayCityInfoData {
    var cityName: String
    var temperature: String
    var weatherStatue: String
    var tempMax: String
    var tempMin: String
}
