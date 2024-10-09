//
//  SearchViewModel.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/7/24.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

final class CitySearchViewModel

{
    // 출력: 도시 리스트
    let filteredCities = BehaviorRelay<[CityDataList]>(value: [])
    let searchCitySelected = PublishSubject<SearchCity>()
    
    // 도시 전체 리스트
    var allCities = BehaviorRelay<[CityDataList]>(value: [])
    
    private let disposeBag = DisposeBag()
    
    func citySelected(_ city: SearchCity) {
        if let lat = city.lat, let lon = city.lon {
            let selectedCity = SearchCity(cityName: city.cityName, lat: String(lat), lon: String(lon))
            searchCitySelected.onNext(selectedCity)
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
    
}

