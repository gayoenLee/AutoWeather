//
//  WeatherModel.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/5/24.
//

import Foundation

struct WeatherModel: Decodable, Equatable {
    
    let cod: String
    let message, cnt: Int
    let list: [WeatherList]
    let city: City
}

// MARK: - City
struct City: Codable,Equatable {
    let id: Int
    let name: String
    let coord: Coord
    let country: String
    let population, timezone, sunrise, sunset: Int
}

// MARK: - Coord
struct Coord: Codable,Equatable {
    let lat, lon: Double
}

// MARK: - List
struct WeatherList: Codable,Equatable {
    let dt: Int
    let main: Main
    let weather: [Weather]
    let clouds: Clouds
    let wind: Wind
    let visibility: Int
    let pop: Double
    let rain: Rain?
    let sys: Sys
    let dtTxt: String

    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, visibility, pop, rain, sys
        case dtTxt = "dt_txt"
    }
}

// MARK: - Clouds
struct Clouds: Codable,Equatable {
    let all: Int
}

// MARK: - Main
struct Main: Codable,Equatable {
    let temp, feelsLike, tempMin, tempMax: Double
    let pressure, seaLevel, grndLevel, humidity: Int
    let tempKf: Double

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
        case humidity
        case tempKf = "temp_kf"
    }
}

// MARK: - Rain
struct Rain: Codable,Equatable {
    let the3H: Double

    enum CodingKeys: String, CodingKey {
        case the3H = "3h"
    }
}

// MARK: - Sys
struct Sys: Codable,Equatable {
    let pod: String
}

// MARK: - Weather
struct Weather: Codable,Equatable {
    let id: Int
    let main, description, icon: String
    
    var koreanDescription: String {
         switch main {
         case "Clear":
             return "맑음"
         case "Clouds":
             return "구름"
         case "Rain":
             return "비"
         case "Drizzle":
             return "이슬비"
         case "Snow":
             return "눈"
         case "Thunderstorm":
             return "천둥"
         default:
             return "알 수 없음"
         }
     }
}

// MARK: - Wind
struct Wind: Codable,Equatable {
    let speed: Double
    let deg: Int
    let gust: Double
}
