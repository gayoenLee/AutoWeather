//
//  WeatherDataViewModelTests.swift
//  WeatherSearchTests
//
//  Created by 이은호 on 10/9/24.
//

import XCTest
import RxSwift
import RxTest
import RxCocoa

@testable import WeatherSearch

final class WeatherDataViewModelTests: XCTestCase {
    var viewModel: WeatherDataViewModel!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        viewModel = WeatherDataViewModel(weatherService: MockWeatherService(), sections: .today)
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewModel = nil
        scheduler = nil
        disposeBag = nil
        super.tearDown()
        
    }

    func testBindInputToFetchWeather_success() throws {
        // Arrange: 입력값과 모의 API 응답
    let testCity = SearchCity(cityName: "Seoul", lat: "37.5665", lon: "126.9780")
    viewModel.searchCity.accept(testCity)
        let observer = scheduler.createObserver(WeatherModel?.self)
        
        viewModel.weatherData
            .asObservable()
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // Act: 스케줄러 진행
        scheduler.start()

        
        // Assert
        let actualWeatherModel = observer.events.first?.value.element
        let expectedWeatherModel = MockWeatherService.mockWeatherData
        
        XCTAssertEqual(actualWeatherModel, expectedWeatherModel)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testBindInputToFetchWeather_failure() {
        // Arrange: 실패 케이스를 시뮬레이션
        let mockService = MockWeatherService()
        mockService.shouldReturnError = true // 에러 반환 설정
        viewModel = WeatherDataViewModel(weatherService: mockService, sections: .today)
        
        let testCity = SearchCity(cityName: "Seoul", lat: "37.5665", lon: "126.9780")
        viewModel.searchCity.accept(testCity)
//
//        let errorObserver = scheduler.createObserver(String?.self)
//
//        viewModel.errorMessage
//            .asObservable()
//            .subscribe(errorObserver)
//            .disposed(by: disposeBag)

        // Act: 스케줄러 진행
        scheduler.start()

        // Assert: 에러 메시지 확인
//        let expectedErrorEvents = [
//            Recorded.next(1, "Failed to fetch weather data"),
//        ]
        XCTAssertEqual(viewModel.errorMessage.value, "Failed to fetch weather data")
    }
}


class MockWeatherService: WeatherService {
    // 모의 응답 데이터를 생성
       static let mockWeatherData = WeatherModel(
           cod: "200",
           message: 0,
           cnt: 1,
           list: [
               WeatherList(
                   dt: 1635782400,
                   main: Main(
                       temp: 289.5,
                       feelsLike: 287.5,
                       tempMin: 288.5,
                       tempMax: 290.5,
                       pressure: 1012,
                       seaLevel: 0,
                       grndLevel: 1,
                       humidity: 72,
                       tempKf: 0.1
                   ),
                   weather: [
                       Weather(id: 800, main: "Clear", description: "clear sky", icon: "01d")
                   ],
                   clouds: Clouds(all: 0),
                   wind: Wind(speed: 1.5, deg: 350, gust: 0.0),
                   visibility: 10000,
                   pop: 0.0,
                   rain: nil,
                   sys: Sys(pod: "d"),
                   dtTxt: "2021-11-01 12:00:00"
               )
           ],
           city: City(
               id: 5128581,
               name: "New York",
               coord: Coord(lat: 40.7128, lon: -74.006),
               country: "US",
               population: 8175133,
               timezone: -14400,
               sunrise: 1635765600,
               sunset: 1635804000
           )
       )

    var shouldReturnError = false
       // `fetchWeather` 메서드는 모의 데이터를 반환하는 역할을 수행
       func fetchWeather(for city: SearchCity) -> Single<WeatherModel> {
           if shouldReturnError{
               print("에러 방출하기")
               return Single.error(NSError(domain: "TestError", code: -1, userInfo: nil))
           }else{
               return Single.just(MockWeatherService.mockWeatherData)

           }
       }
       
       // 모의 응답 JSON 데이터를 디코딩하는 함수
       func decoding() {
           do {
               let jsonData = try JSONSerialization.data(withJSONObject: mockWeatherResponse, options: [])
               let decoder = JSONDecoder()
               let weatherResponse = try decoder.decode(WeatherModel.self, from: jsonData)
               print("Mock data decoded successfully: \(weatherResponse)")
           } catch {
               print("Failed to decode mock data: \(error)")
           }
       }

       // JSON 응답 데이터를 테스트용으로 정의
       let mockWeatherResponse: [String: Any] = [
           "cod": "200",
           "message": 0,
           "cnt": 1,
           "list": [
               [
                   "dt": 1635782400,
                   "main": [
                       "temp": 289.5,
                       "feels_like": 287.5,
                       "temp_min": 288.5,
                       "temp_max": 290.5,
                       "pressure": 1012,
                       "seaLevel": 1,
                       "grndLevel": 3,
                       "humidity": 72,
                       "tempKf":0.1
                   ],
                   "weather": [
                       [
                           "id": 800,
                           "main": "Clear",
                           "description": "clear sky",
                           "icon": "01d"
                       ]
                   ],
                   "clouds": [
                       "all": 0
                   ],
                   "wind": [
                       "speed": 1.5,
                       "deg": 350
                   ],
                   "dt_txt": "2021-11-01 12:00:00"
               ]
           ],
           "city": [
               "id": 5128581,
               "name": "New York",
               "coord": [
                   "lat": 40.7128,
                   "lon": -74.006
               ],
               "country": "US",
               "population": 8175133,
               "timezone": -14400,
               "sunrise": 1635765600,
               "sunset": 1635804000
           ]
       ]
   }
