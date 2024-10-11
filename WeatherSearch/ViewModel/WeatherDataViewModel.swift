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


final class WeatherDataViewModel {
    private let processWeatherDataUseCase: ProcessWeatherDataUseCaseImpl
    private let disposeBag = DisposeBag()
    
    // 테이블뷰에 전달할 데이터를 위한 Observable
    let fullWeatherData = BehaviorRelay<FullWeatherData?>(value: nil)
    //도시 이름, 위도 및 경도 입력을 위한 Relay
    var searchCity = BehaviorRelay<SearchCity?>(value: nil)
    let isLoading = BehaviorRelay<Bool>(value: true)
    var errorMessage = BehaviorRelay<String?>(value: nil)
    private var calendar = Calendar.current
    
    init(processWeatherDataUseCase: ProcessWeatherDataUseCaseImpl) {
        self.processWeatherDataUseCase = processWeatherDataUseCase
    }
    
     func bindInputToFetchWeather() {
        getSearchCity()
            .flatMapLatest { [weak self] city -> Single<FullWeatherData> in
                
                guard let self = self else {
                    self?.updateUIWithFetchedData(nil, loadingState: false)
                    self?.handleFetchError(CityListError.deallocated)
                    return Single.error(NSError(domain: "WeatherApp", code: -1, userInfo: [NSLocalizedDescriptionKey: "ViewModel is deallocated"]))
                }
                return self.processWeatherDataUseCase.execute(for: city)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] processedResult in
                self?.updateUIWithFetchedData(processedResult, loadingState: false)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleFetchError(_ error: Error) {
        DispatchQueue.main.async {
             self.isLoading.accept(false)
             self.errorMessage.accept("Failed to fetch weather data: \(error.localizedDescription)")
         }
    }
    
    private func getSearchCity() -> Observable<SearchCity> {
        return searchCity
            .compactMap { $0 ?? SearchCity(cityName: "Asan", lat: "36.783611", lon: "127.004173") }
            .distinctUntilChanged()
    }
    // UI 상태 업데이트
    private func updateUIWithFetchedData(_ result: FullWeatherData?, loadingState: Bool) {
        
        DispatchQueue.main.async {
            if let result = result {
                self.fullWeatherData.accept(result)
                self.isLoading.accept(loadingState)
            }
        }
    }
    
    
}
