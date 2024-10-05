//
//  WeatherService.swift
//  YourWeather
//
//  Created by 이은호 on 10/4/24.
//

import Foundation
import Alamofire


class WeatherAPIService: WeatherService {
    
    private var apiKey: String? {
        guard let filePath = Bundle.main.path(forResource: "KeyList", ofType: "plist") else {
            fatalError("Not foumd KeyList file")
        }
        do{
            // .plist를 딕셔너리로 받아오기
            let plist = NSDictionary(contentsOfFile: filePath)
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            if let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print(jsonDictionary) // JSON 딕셔너리 출력
                
                // 딕셔너리에서 값 찾기
                guard let value = plist?.object(forKey: "OPENWEATHERMAP_KEY") as? String else {
                    fatalError("Couldn't find key 'OPENWEATHERMAP_KEY' in 'KeyList.plist'.")
                }
                
                return value
            } else {
                print("JSON 형식이 맞지 않습니다.")
            }
        } catch {
            print("Error rading json file: \(error)")
        }
      return nil
    }
    
    
    
    func fetchWeather() {
        
    }
    
}
