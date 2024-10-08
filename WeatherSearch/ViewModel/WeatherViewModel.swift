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

final class WeatherViewModel {
    
    private let weatherService: WeatherService
    private let disposeBag = DisposeBag()
    
    // 테이블뷰에 전달할 데이터를 위한 Observable
    let dailyWeatherData: BehaviorRelay<[(dayOfWeek: String, tempMax: Double, tempMin: Double, weatherIcon: String)]> = BehaviorRelay(value: [])
    let averageData = BehaviorRelay<(humidity: Double, clouds: Double, wind: Double)?>(value:(nil))
    //도시 이름, 위도 및 경도 입력을 위한 Relay
    var searchCity = BehaviorRelay<SearchCity?>(value: nil)
    //결과 저장
    var weatherData = BehaviorRelay<WeatherModel?>(value: nil)
    // 출력: 도시 리스트
    let filteredCities = BehaviorRelay<[CityDataList]>(value: [])
    
    // 도시 전체 리스트
    let allCities = BehaviorRelay<[CityDataList]>(value: [])
    
    var isLoading = BehaviorRelay<Bool>(value: false)
    var errorMessage = PublishRelay<String>()
    
    var sections : WeatherCollectionViewCellType
    
    init(weatherService: WeatherService, sections: WeatherCollectionViewCellType) {
        self.weatherService = weatherService
        self.sections = sections
        bindInputToFetchWeather()
        
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
        
        self.averageData.accept((averageHumidity, averageClouds, averageWindSpeed))
    }
    
    func processDailyWeatherData(_ weatherModel: WeatherModel) {
        let groupedData = self.groupWeatherByDay(weatherModel.list)
        
        //일별로 최대, 최저 기온 및 날씨 아이콘 결정
        let processedData = groupedData.map { (day, data) -> (String, Double, Double, String) in
            let maxTemp = data.map { $0.main.tempMax }.max() ?? 0
            let minTemp = data.map { $0.main.tempMin }.min() ?? 0
            let weatherIcon = self.determineMostFrequentOrSevereIcon(from: data.map { $0.weather.first?.id ?? 800 })
            return (day, maxTemp, minTemp, weatherIcon)
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
    
    private func bindInputToFetchWeather() {
        print("페치 웨더")
        searchCity
            .compactMap { $0 ?? SearchCity(cityName: "Asan", lat: "36.783611", lon: "127.004173") }
            .distinctUntilChanged() //동일한 값은 무시하는 것
            .flatMapLatest { [weak self] city-> Single<WeatherModel> in
                
                guard let self = self else {
                    print("self is nil, stop flow")
                    return .never()}
                self.isLoading.accept(true)
                print("Fetching weather for city: \(city)")
                
                return self.weatherService.fetchWeather(for: city)
                    .do(onSuccess: { _ in
                        self.isLoading.accept(false)
                        print("Success: Weather data fetched successfully")
                    }, onError: { error in
                        print("Error: \(error)")
                        self.isLoading.accept(false)
                        self.errorMessage.accept("Failed to fetch weather data")
                    })
            }
        
            .subscribe(onNext: {[weak self] weatherModel in
                print("여기로 오는지: \(weatherModel)")
                self?.processDailyWeatherData(weatherModel)
                self?.calculateAverageHumidWind(weatherModel.list)
                self?.weatherData.accept(weatherModel)
                
            })
            .disposed(by: disposeBag)
    }
    
    func selectedInSearchBar(with city: SearchCity) {
        searchCity.accept(city)
    }
    
    func loadCityData()  {
        print("loadcityData weatherviewcontroller에서 실행")
        DispatchQueue.global().async {
            // 1. 번들에서 JSON 파일 경로 찾기
            guard let path = Bundle.main.path(forResource: "citylist", ofType: "json") else {
                print("파일을 찾을 수 없습니다.")
                return
            }
            
            // 2. 파일 경로에서 데이터 읽기
            let url = URL(fileURLWithPath: path)
            do {
                let data = try Data(contentsOf: url)
                
                // 3. JSON 데이터 디코딩
                let decoder = JSONDecoder()
                let cityList = try decoder.decode([CityDataList].self, from: data)
                print("데이터 다 가져옴")
                DispatchQueue.main.async {
                    self.filteredCities.accept(cityList)
                    self.allCities.accept(cityList)
                }
            } catch {
                print("JSON 파일을 디코딩하는 중 에러 발생: \(error)")
            }
        }
    }
    
    
    
    // 도시 필터링 로직
    func filterCities(with searchText: String) {
        if searchText.isEmpty {
            filteredCities.accept(allCities.value)  // 검색어가 없으면 전체 도시 표시
        } else {
            let filtered = allCities.value.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            filteredCities.accept(filtered)
        }
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
