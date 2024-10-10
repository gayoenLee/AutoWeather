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
    var errorMessage = BehaviorRelay<String?>(value: nil)

    private let disposeBag = DisposeBag()
    
    // 도싣 선택히 SearchCity 반환
    func citySelected(_ city: SearchCity) -> SearchCity?{
        guard let lat = city.lat, let lon = city.lon else {
            errorMessage.accept("Not valid city")
            return nil
        }
     
            let selectedCity = SearchCity(cityName: city.cityName, lat: String(lat), lon: String(lon))
            searchCitySelected.onNext(selectedCity)
        return selectedCity
        
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
    
    // 파일에서 데이터를 비동기적으로 로드하는 함수
    private func loadCityDataFromFile() async throws -> [CityDataList] {
        // 1. 번들에서 JSON 파일 경로 찾기
        guard let path = Bundle.main.path(forResource: "citylist", ofType: "json") else {
            throw NSError(domain: "CityListError", code: -1, userInfo: [NSLocalizedDescriptionKey: "파일을 찾을 수 없습니다."])
        }
        
        // 2. 파일 경로에서 데이터 읽기
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        
        // 3. JSON 데이터 디코딩
        let decoder = JSONDecoder()
        let cityList = try decoder.decode([CityDataList].self, from: data)
        return cityList
    }
    
    func loadCityData()  {
        Single<[CityDataList]>.create { single in
            Task {
                do {
                    let cityData = try await self.loadCityDataFromFile()
                    single(.success(cityData))
                }catch {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
        .subscribe(onSuccess: { [weak self] cityList in
            guard let self = self else { return }
            self.filteredCities.accept(cityList)
            self.allCities.accept(cityList)
        }, onFailure: { error in
            print("에러 발생: \(error.localizedDescription)")
            self.handleError(error.localizedDescription)
        })
        .disposed(by: disposeBag)
    }
    
    private func handleError(_ message: String) {
        print("에러 처리: \(message)")
        DispatchQueue.main.async {
            // 예: UI에 오류 메시지 표시나 상태 업데이트
            self.errorMessage.accept(message)
        }
    }
}

