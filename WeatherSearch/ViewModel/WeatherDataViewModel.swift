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

enum CityFileError: Error {
    case fileNotFound
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

struct TodayCityInfoData {
    var cityName: String
    var temperature: String
    var weatherStatue: String
    var tempMax: String
    var tempMin: String
}

final class WeatherDataViewModel {
    
    private let weatherService: WeatherService
    private let disposeBag = DisposeBag()
    
    // 테이블뷰에 전달할 데이터를 위한 Observable
    let todayCityInfoData: BehaviorRelay<TodayCityInfoData?> = BehaviorRelay(value: nil)
    let dailyWeatherData: BehaviorRelay<[DailyWeatherData]?> = BehaviorRelay(value: nil)
    let averageData = BehaviorRelay<AverageWeatherData?>(value:(nil))
    let threeHourData: BehaviorRelay<[ThreeHourWeatherData]?> = BehaviorRelay(value: nil)
    // 전체 날씨 데이터 결과 저장
    var weatherData = BehaviorRelay<WeatherModel?>(value: nil)
    //도시 이름, 위도 및 경도 입력을 위한 Relay
    var searchCity = BehaviorRelay<SearchCity?>(value: nil)
    
    var isLoading = BehaviorRelay<Bool>(value: false)
    var errorMessage = BehaviorRelay<String?>(value: nil)
    
    
    init(weatherService: WeatherService) {
        self.weatherService = weatherService
        bindInputToFetchWeather()

    }
    
    private func bindInputToFetchWeather() {
        searchCity
            .compactMap { $0 ?? SearchCity(cityName: "Asan", lat: "36.783611", lon: "127.004173") }
            .distinctUntilChanged() //동일한 값은 무시하는 것
            .flatMapLatest { [weak self] city-> Single<WeatherModel> in
                // 안정성, 메모리 누수 방지
                guard let self = self else {
                    print("self is nil, stop flow")
                    return .never()
                }
                self.isLoading.accept(true)
                
                return self.weatherService.fetchWeather(for: city)
                    .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .do(onSuccess: { _ in
                        DispatchQueue.main.async {
                            self.isLoading.accept(false)
                        }

                        print("Success: Weather data fetched successfully")
                    }, onError: { error in
                        print("Error: \(error)")
                        DispatchQueue.main.async {
                            self.isLoading.accept(false)
                            self.errorMessage.accept("Failed to fetch weather data")
                        }
                    })
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] weatherModel in
                self?.processTodyaCityInfoData(weatherModel)
                self?.processThreeHourData(Array(weatherModel.list.prefix(18)))
                self?.processDailyWeatherData(weatherModel)
                self?.calculateAverageHumidWind(weatherModel.list)
                self?.weatherData.accept(weatherModel)
                
            })
            .disposed(by: disposeBag)
    }
    
    private func processTodyaCityInfoData(_ weatherModel: WeatherModel) {
        let recentData = weatherModel.list[0]
        let name = weatherModel.city.name
        let temperature = String(recentData.main.temp)
        let condition = String(recentData.weather[0].koreanDescription)
        let high = Int(recentData.main.tempMax)
        let low = Int(recentData.main.tempMin)
        let result = TodayCityInfoData(cityName: name, temperature: temperature, weatherStatue: condition, tempMax: String(high), tempMin: String(low))
        self.todayCityInfoData.accept(result)
    }
    
    
    private func processThreeHourData(_ weatherList: [WeatherList]) {
        let data = filterDataForTwoDays(weatherList)
        var result : [ThreeHourWeatherData] = []
        guard let data = data else { return }
        for (idx,weather) in data.enumerated() {
            var time = ""
            if idx == 0 {
                time = "지금"
            }else{
                time = weather.dtTxt.convertTimeToLabel(time: weather.dtTxt)
            }
            let temperature = String(weather.main.temp)
            let iconName = getWeatherIcon(id: weather.weather[0].id)
            var item = ThreeHourWeatherData(time: time, iconName: iconName, temperature: temperature)
            result.append(item)
        }
        self.threeHourData.accept(result)

    }
    
    
    private func filterDataForTwoDays(_ weatherList: [WeatherList]) -> [WeatherList]? {
        // 현재 한국 시간을 구함
        let currentDate = Date()
        print("현재 한국 시간: \(currentDate)")
        let convertedData = currentDate.toUTC()
        if let minDate = convertedData.0, let minHour = convertedData.1{
            print("최소: \(minDate), 시각만: \(minHour)") // 시간만(hour) 가져와서 비교
            
            let maxTime = minDate.addOneDay()!
            print("최대: \(maxTime)")
            
            let filteredData = weatherList.compactMap({ weather in
                if let val = weather.dtTxt.isoStringToDate(dateString: weather.dtTxt) {
                    if minHour <= val && val <= maxTime {
                        return weather
                    }
                }
                return nil
            })
            return filteredData
        }
        return nil
    }
    
    func calculateAverageHumidWind(_ weatherList: [WeatherList]) {
        
        // 습도 평균 계산
        let totalHumidity = weatherList.map { Double($0.main.humidity) }.reduce(0, +)
        let averageHumidity = totalHumidity / Double(weatherList.count)
        
        // 구름 평균 계산
        let totalClouds = weatherList.map { Double($0.clouds.all) }.reduce(0, +)
        let averageClouds = totalClouds / Double(weatherList.count)
        
        // 바람 속도 평균 계산
        let totalWindSpeed = weatherList.map { $0.wind.speed }.reduce(0, +)
        let averageWindSpeed = totalWindSpeed / Double(weatherList.count)
        let result = AverageWeatherData(humidity: String(format: "%.0f%%", averageHumidity), clouds: String(format: "%.0f%%", averageClouds), windSpeed: String(format: "%.2f m/s", averageWindSpeed))
        self.averageData.accept(result)
    }
    
    func processDailyWeatherData(_ weatherModel: WeatherModel) {
        let groupedData = self.groupWeatherByDay(weatherModel.list)
        
        //일별로 최대, 최저 기온 및 날씨 아이콘 결정
        let processedData = groupedData.map { (day, data) -> DailyWeatherData in
            let maxTemp = data.map { $0.main.tempMax }.max() ?? 0
            let minTemp = data.map { $0.main.tempMin }.min() ?? 0
            let weatherIcon = self.determineMostFrequentOrSevereIcon(from: data.map { $0.weather.first?.id ?? 800 })
            let icon = getWeatherIcon(id: Int(weatherIcon) ?? 800)
            let result = DailyWeatherData(dayOfWeek: day, icon: icon,tempMax: maxTemp, tempMin: minTemp)
            return result
        }
        dailyWeatherData.accept(processedData)
    }
    
    // 데이터 그룹화 함수
    private func groupWeatherByDay(_ weatherList: [WeatherList]) -> [String: [WeatherList]] {
        var groupedWeather = [String: [WeatherList]]()
        let calendar = Calendar.current
        
        for weather in weatherList {
            let date = Date(timeIntervalSince1970: TimeInterval(weather.dt))
            let day = calendar.startOfDay(for: date).dayOfWeek()
            
            if groupedWeather[day] != nil {
                groupedWeather[day]?.append(weather)
            } else {
                groupedWeather[day] = [weather]
            }
        }
        return groupedWeather
    }
    
    // 날씨 id 값들을 분석해서 가장 중요한 아이콘을 결정하는 함수
    private func determineMostFrequentOrSevereIcon(from weatherIds: [Int]) -> String {
        // 우선순위 높은 순서로 날씨 id를 정렬 (폭풍우, 비, 구름, 맑음 순서로 중요도 판단)
        let weatherPriority: [Int] = [200...232, 300...321, 500...531, 600...622, 701...781, 800...800, 801...804].flatMap { $0 }
        
        // 가장 우선순위 높은 날씨 id를 찾음
        if let importantWeatherId = weatherIds.first(where: { weatherPriority.contains($0) }) {
            
            return getWeatherIcon(id: importantWeatherId)
        }
        return "11d"  // 기본 아이콘
    }
    
    private func getWeatherIcon(id: Int) -> String {
        switch id {
        case 200...232:
            return "11d"
        case 300...321:
            return "09d"
        case 500...504:
            return "10d"
        case 511:
            return "13d"
        case 520...531:
            return "09d"
        case 600...622:
            return "13d"
        case 701...781:
            return "50d"
        case 800:
            return "01d"
        case 801:
            return "02d"
        case 802:
            return "03d"
        case 803...804:
            return "04d"
        default:
            return "알 수 없음"
        }
    }
}
