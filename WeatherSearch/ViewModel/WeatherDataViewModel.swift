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

final class WeatherDataViewModel {
    
    private let weatherService: WeatherServiceProtocol
    private let disposeBag = DisposeBag()
    
    // 테이블뷰에 전달할 데이터를 위한 Observable
    let fullWeatherData = BehaviorRelay<FullWeatherData?>(value: nil)
    //도시 이름, 위도 및 경도 입력을 위한 Relay
    var searchCity = BehaviorRelay<SearchCity?>(value: nil)
    var isLoading = BehaviorRelay<Bool>(value: false)
    var errorMessage = BehaviorRelay<String?>(value: nil)
    private var calendar = Calendar.current
    
    init(weatherService: WeatherServiceProtocol) {
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
                    return Single.error(NSError(domain: "WeatherApp", code: -1, userInfo: [NSLocalizedDescriptionKey: "ViewModel is deallocated"]))
                }
                self.isLoading.accept(true)
                return self.weatherService.fetchWeather(for: city)
                    .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .do(onSuccess: { _ in
                        print("Success: Weather data fetched successfully")
                    }, onError: { error in
                        
                        DispatchQueue.main.async {
                            self.isLoading.accept(false)
                            self.errorMessage.accept("Failed to fetch weather data")
                        }
                    })
            }
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] weatherModel -> Observable<FullWeatherData?> in
                guard let self = self else { return Observable.just(nil) }
                
                // 백그라운드 작업은 Rx에서 처리
                return Observable.create { observer in
                    Task {
                        let result = try await self.processDataInBackground(weatherModel)
                        observer.onNext(result)
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            }
            .subscribe(onNext: { [weak self] processedResult in
                guard let self = self, let result = processedResult else { return }
                self.fullWeatherData.accept(result)
                
                // 데이터가 렌더링되었을 때 로딩 상태를 false로 설정
                DispatchQueue.main.async {
                    self.isLoading.accept(false)
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    private func processDataInBackground(_ weatherModel: WeatherModel) async throws -> FullWeatherData? {
        
        async let todayCityInfo = self.processTodyaCityInfoData(weatherModel)
        
        // 3시간 데이터 생성 및 전달
        async let threeHourData = self.processThreeHourData(Array(weatherModel.list.prefix(18)))
        // 일일 데이터 생성 및 전달
        async let dailyWeatherData = self.processDailyWeatherData(weatherModel)
        async let mapData = self.processMapData(weatherModel)
        
        // 평균 데이터 생성 및 전달
        async let averageData = self.calculateAverageHumidWind(weatherModel.list)
        // 가공된 데이터를 모두 모아 FullWeatherData를 생성합니다.
        let fullWeatherData = try await FullWeatherData(
            todayCityInfo: todayCityInfo,
            threeHourData: threeHourData,
            dailyWeatherData: dailyWeatherData,
            mapLocationData: mapData, averageData: averageData
        )
        return fullWeatherData
    }
    
    private func processMapData(_ weatherModel: WeatherModel) -> MapLocationData {
        return MapLocationData(lat: String(weatherModel.city.coord.lat), lon: String(weatherModel.city.coord.lon))
    }
    
    private func processTodyaCityInfoData(_ weatherModel: WeatherModel) -> TodayCityInfoData {
        let recentData = weatherModel.list[0]
        let name = weatherModel.city.name
        let temperature = String(recentData.main.temp)
        let condition = String(recentData.weather[0].koreanDescription)
        let high = Int(recentData.main.tempMax)
        let low = Int(recentData.main.tempMin)
        return TodayCityInfoData(cityName: name, temperature: temperature, weatherStatue: condition, tempMax: String(high), tempMin: String(low))
    }
    
    
    private func processThreeHourData(_ weatherList: [WeatherList]) async -> [ThreeHourWeatherData]? {
        let filteredData = filterDataForTwoDays(weatherList)
        guard let filteredData = filteredData else { return nil}
        var result = Array<ThreeHourWeatherData?>(repeating: nil, count: filteredData.count)

         await withTaskGroup(of: (Int,ThreeHourWeatherData?).self) { group in
            
            for (idx, weather) in filteredData.enumerated() {
                group.addTask {
                    var time = ""
                    if idx == 0 {
                        time = "지금"
                    } else {
                        guard let date = weather.dtTxt.convertISOStringToDate() else { return (idx,nil) }
                        time = date.toKoreanTimeWithAMPM()
                    }
                    let temperature = String(weather.main.temp)
                    let iconName = self.getWeatherIcon(id: weather.weather[0].id)
                    let data = ThreeHourWeatherData(time: time, iconName: iconName, temperature: temperature)
                    return (idx,data)
                }
            }
            for await (idx,weatherData) in group {
                if let weatherData = weatherData {
                    result[idx] = weatherData
                }
            }
        }
        return result.compactMap { $0 }

    }
    
    
    private func filterDataForTwoDays(_ weatherList: [WeatherList]) -> [WeatherList]? {
        // 현재 한국 시간을 구함
        let standardTime = Date().getMinMaxTimeRange()
        guard let minTime = standardTime?.0, let maxTime = standardTime?.1 else { return [] }
            
            let filteredData = weatherList.filter({ weather in
                if let val = weather.dtTxt.convertISOStringToDate() {
                    return minTime <= val && val <= maxTime
                }
                return false
            })
            return filteredData
    }
    
    func calculateAverageHumidWind(_ weatherList: [WeatherList]) -> AverageWeatherData {
        
        // 습도 평균 계산
        let totalHumidity = weatherList.map { Double($0.main.humidity) }.reduce(0, +)
        let averageHumidity = totalHumidity / Double(weatherList.count)
        
        // 구름 평균 계산
        let totalClouds = weatherList.map { Double($0.clouds.all) }.reduce(0, +)
        let averageClouds = totalClouds / Double(weatherList.count)
        
        // 바람 속도 평균 계산
        let totalWindSpeed = weatherList.map { $0.wind.speed }.reduce(0, +)
        let averageWindSpeed = totalWindSpeed / Double(weatherList.count)
        return AverageWeatherData(humidity: String(format: "%.0f%%", averageHumidity), clouds: String(format: "%.0f%%", averageClouds), windSpeed: String(format: "%.2f m/s", averageWindSpeed))
    }
    
    func processDailyWeatherData(_ weatherModel: WeatherModel) async -> [DailyWeatherData]{
        let groupedData = self.groupWeatherByDay(weatherModel.list)
        var result = Array<DailyWeatherData?>(repeating: nil, count: groupedData.count)
        
         await withTaskGroup(of: (Int, DailyWeatherData?).self) { group in
            for (index, (day, data)) in groupedData.enumerated() {
                group.addTask {
                    let maxTemp = data.map { $0.main.tempMax }.max() ?? 0
                    let minTemp = data.map { $0.main.tempMin }.min() ?? 0
                    let weatherIcon = self.determineMostFrequentOrSevereIcon(from: data.map { $0.weather.first?.id ?? 800 })
                    let icon = self.getWeatherIcon(id: Int(weatherIcon) ?? 800)
                    let dailyData = DailyWeatherData(dayOfWeek: day, icon: icon,tempMax: maxTemp, tempMin: minTemp)
                    return (index, dailyData)
                }
            }
            
            for await (index,dailyData) in group {
                if let dailyData = dailyData {
                    result[index] = dailyData
                }
            }
            print("변환 후 데이터 확인: \(result)")
        }
        return result.compactMap { $0 }
    }
    
    // 데이터 그룹화 함수
    private func groupWeatherByDay(_ weatherList: [WeatherList]) -> [(String, [WeatherList])] {
        var groupedWeather = [(String, [WeatherList])]()
        // 한국 표준시 (KST) 타임존 설정
        let koreaTimeZone = TimeZone(identifier: "Asia/Seoul")!
        calendar.timeZone = koreaTimeZone
        var currentDay: String? = nil
          var currentGroup: [WeatherList] = []

          // 이미 시간 순서대로 정렬된 weatherList를 순회하면서 그룹화
          for weather in weatherList {
              if let localDate = weather.dtTxt.convertISOStringToDate() {
                  let dayString = localDate.toKoreanDayString()

                  if currentDay == nil {
                      currentDay = dayString
                  }

                  // 요일이 바뀌면 기존 데이터를 그룹에 추가하고 새로운 그룹을 시작
                  if currentDay == dayString {
                      currentGroup.append(weather)
                  } else {
                      // 이전 요일의 데이터를 추가
                      if let currentDay = currentDay {
                          groupedWeather.append((currentDay, currentGroup))
                      }

                      // 새로운 요일로 그룹 시작
                      currentDay = dayString
                      currentGroup = [weather]
                  }
              }
          }

          // 마지막 그룹 추가
          if let currentDay = currentDay {
              groupedWeather.append((currentDay, currentGroup))
          }
        print("요일만 확인: \(groupedWeather.map({ $0.0}))")
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
