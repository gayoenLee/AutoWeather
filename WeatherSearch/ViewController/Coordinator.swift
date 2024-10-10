//
//  Coordinator.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/10/24.
//

import Foundation
import UIKit
import RxSwift

protocol Coordinator {
    var navigationController: UINavigationController { get set }
    func start()
}

final class AppCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    
    private let disposeBag = DisposeBag()
    private lazy var weatherViewController: WeatherViewController = {
        
        let weatherService = WeatherAPIService()
        let repository = WeatherRepositoryImpl(weatherService: weatherService)
        let weatherUseCase = ProcessWeatherDataUseCaseImpl(repository: repository)
        let viewModel = WeatherDataViewModel(processWeatherDataUseCase: weatherUseCase)
        
        let searchVM = CitySearchViewModel()
        let dataSource = WeatherCollectionViewDataSource()
        let mainViewController = WeatherViewController(viewModel: viewModel, searchVM: searchVM, dataSource: dataSource)
        
        return mainViewController
    }()
    
    private lazy var searchViewController: SearchViewController = {
          let searchVC = SearchViewController(viewModel: self.weatherViewController.viewModel, searchVM: weatherViewController.searchVM)
          return searchVC
      }()

      init(navigationController: UINavigationController) {
          self.navigationController = navigationController
      }
    
    // 앱 시작 시 WeatherViewController를 설정
    func start() {
        navigationController.setViewControllers([weatherViewController], animated: true)
        bindWeatherViewController()
    }
    
    
    // WeatherViewController에서 발생하는 이벤트 처리
    private func bindWeatherViewController() {
        weatherViewController.searchBarTapped
            .subscribe(onNext: { [weak self] in
                self?.showSearchViewController()
            })
            .disposed(by: disposeBag)

        weatherViewController.viewModel.searchCity
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] city in
                self?.navigationController.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

    // SearchViewController로 전환
    private func showSearchViewController() {
        navigationController.pushViewController(searchViewController, animated: true)
    }
}
