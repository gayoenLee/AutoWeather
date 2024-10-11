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
    let filteredCities = BehaviorRelay<[CityDataList]>(value: [])
    let searchCitySelected = PublishSubject<SearchCity>()
    var allCities = BehaviorRelay<[CityDataList]>(value: [])
    var errorMessage = BehaviorRelay<String?>(value: nil)
    private let disposeBag = DisposeBag()
    
    // 도시 리스트 파일 읽어오기
    private func loadCityDataFromFile() async throws -> [CityDataList] {
        // 1. 번들에서 JSON 파일 경로 찾기
        guard let path = Bundle.main.path(forResource: "citylist", ofType: "json") else {
        
            throw CityListError.fileNotFound
        }
        
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)        
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
            self.handleError(error.localizedDescription)
        })
        .disposed(by: disposeBag)
    }
    
    private func handleError(_ message: String) {
        DispatchQueue.main.async {
            // 예: UI에 오류 메시지 표시나 상태 업데이트
            self.errorMessage.accept(message)
        }
    }
}

