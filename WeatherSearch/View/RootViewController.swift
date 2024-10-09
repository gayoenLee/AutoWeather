//
//  RootViewController.swift
//  YourWeather
//
//  Created by 이은호 on 10/4/24.
//

import UIKit
import RxCocoa
import RxSwift


final class RootViewController: UINavigationController {
    private let disposeBag = DisposeBag()

    
    private lazy var weatherViewController: WeatherViewController = {
        let service = WeatherAPIService()
        let viewModel = WeatherDataViewModel(weatherService: service)
        let searchVM = CitySearchViewModel()
        let mainViewController = WeatherViewController(viewModel: viewModel, searchVM: searchVM)
        return mainViewController
    }()
    
    private lazy var searchViewController: SearchViewController = {
        let searchVC = SearchViewController(viewModel: self.weatherViewController.viewModel, searchVM: weatherViewController.searchVM)
        return searchVC
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewControllers([weatherViewController], animated: true)
        bindWeatherViewController()
        selectedSearchCity()
    }
     
     // 다시 날씨 화면으로 돌아가는 함수
     func switchToWeatherViewController() {
             setViewControllers([weatherViewController], animated: true)  // 날씨 화면으로 전환
         }
    
    private func bindWeatherViewController() {
        weatherViewController.searchBarTapped
            .subscribe(onNext: { [weak self] in
                print("weather - 검색바 클릭 이벤트 루트에서 받음")
                self?.showSearchViewController()
            })
            .disposed(by: disposeBag)
    }
    
    private func showSearchViewController() {
        print("검색 뷰컨트롤러 보여주기")
        self.popViewController(animated: true)
        pushViewController(searchViewController, animated: true)
        
    }
    
    private func selectedSearchCity() {
   
        //search에서 도시 선택시 weatherVC로 데이터 전달
        weatherViewController.viewModel.searchCity
            .distinctUntilChanged()
                .subscribe(onNext: { [weak self] city in
                    guard let self = self else { return }
                    print("도시 선택해서 루트에서 받음: \(String(describing: city))")
                    
//                      self.weatherViewController.selectedInSearchBar(with: city)
                      self.popViewController(animated: true) 

                  })
                  .disposed(by: disposeBag)
    }
}
