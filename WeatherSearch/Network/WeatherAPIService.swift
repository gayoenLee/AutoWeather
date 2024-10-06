//
//  WeatherService.swift
//  YourWeather
//
//  Created by 이은호 on 10/4/24.
//

import Foundation
import Alamofire
import RxSwift



class WeatherAPIService: WeatherService {
    
    static func getApiKey()-> String {
        guard let filePath = Bundle.main.url(forResource: "KeyList", withExtension: "plist") else {
            fatalError("Not foumd KeyList file")
        }
        do{
            
            guard let plistData = try? Data(contentsOf: filePath),
                  let dict = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? NSDictionary else {
                fatalError("Couldn't find key 'OPENWEATHERMAP_KEY' in 'KeyList.plist'.")
            }
        let value = dict["OPENWEATHERMAP_KEY"] as! String
            return value
        } catch {
            print("Error rading json file: \(error)")
        }
      //return nil
    }
    
    
    
    func fetchWeather(for city: String)  {
    }
    
}
