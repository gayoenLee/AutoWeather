//
//  CityList.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/7/24.
//
import Foundation


struct CityDataList: Codable, Equatable {
    let id: Int
    let name, country: String
    let coord: Coord
    
    // MARK: - Coord
    struct Coord: Codable, Equatable {
        let lon, lat: Double
    }
}



typealias CityDictionary = [CityDataList]
