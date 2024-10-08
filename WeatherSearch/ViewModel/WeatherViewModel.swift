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
    
    let searchText = BehaviorRelay<String>(value: "")
    //도시 이름, 위도 및 경도 입력을 위한 Relay
    var searchCity = BehaviorRelay<SearchCity?>(value: nil)
    //결과 저장
    var weatherData = BehaviorRelay<WeatherModel?>(value: nil)
    // 출력: 도시 리스트
    let filteredCities = BehaviorRelay<[CityDataList]>(value: [])
    
    // 도시 전체 리스트
    private var allCities = BehaviorRelay<[CityDataList]>(value: [])
    
    var isLoading = BehaviorRelay<Bool>(value: false)
    var errorMessage = PublishRelay<String>()

    var sections : WeatherCollectionViewCellType
    
    init(weatherService: WeatherService, sections: WeatherCollectionViewCellType) {
        self.weatherService = weatherService
        self.sections = sections
        bindInputToFetchWeather()
        
        // 검색어에 따른 필터링 로직
             searchText
                 .distinctUntilChanged()
                 .flatMapLatest { query -> Observable<[CityDataList]> in
                     if query.isEmpty {
                         return Observable.just(self.allCities.value)  // 검색어가 없을 때 전체 도시 반환
                     } else {
                         let filtered = self.allCities.value.filter { $0.name.lowercased().contains(query.lowercased()) }
                         return Observable.just(filtered)
                     }
                 }
                 .bind(to: filteredCities)
                 .disposed(by: disposeBag)
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
                self?.weatherData.accept(weatherModel)
            })
            .disposed(by: disposeBag)
        
        func selectedInSearchBar(with city: SearchCity) {
            searchCity.accept(city)
        }
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
