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

final class SearchViewModel

{
    // 입력: 검색할 도시명
      let searchText = PublishRelay<String>()
      
      // 출력: 도시 리스트
      let filteredCities = BehaviorRelay<[CityDataList]>(value: [])
      
      // 도시 전체 리스트
      private var allCities = BehaviorRelay<[CityDataList]>(value: [])
      
      private let disposeBag = DisposeBag()
    private var hasLoadedCities = false  // 데이터가 이미 로드되었는지 체크하는 변수

      init() {
          // JSON에서 도시 리스트 로드
          if let result = loadCityData() {
              self.allCities.accept(result)
              self.filteredCities.accept(result)
          }
          
      }
      
      private func loadCityData() -> [CityDataList]? {
          print("loadcityData 실행")
          // 이미 데이터를 로드했으면 다시 로드하지 않음
                guard !hasLoadedCities else { return nil }
                hasLoadedCities = true
          
          
          // 1. 번들에서 JSON 파일 경로 찾기
              guard let path = Bundle.main.path(forResource: "citylist", ofType: "json") else {
                  print("파일을 찾을 수 없습니다.")
                  return nil
              }
              
              // 2. 파일 경로에서 데이터 읽기
              let url = URL(fileURLWithPath: path)
              do {
                  let data = try Data(contentsOf: url)
                  
                  // 3. JSON 데이터 디코딩
                  let decoder = JSONDecoder()
                  let cityList = try decoder.decode([CityDataList].self, from: data)
                  return cityList
                  
              } catch {
                  print("JSON 파일을 디코딩하는 중 에러 발생: \(error)")
                  return nil
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
  }
