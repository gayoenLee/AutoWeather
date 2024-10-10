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
    
    private lazy var loadingViewController = {
        let loadingViewController = LoadingViewController()
        return loadingViewController
    }()

    private let window: UIWindow

    init(navigationController: UINavigationController, window: UIWindow) {
          self.navigationController = navigationController
        self.window = window
      }
    
    // 앱 시작 시 WeatherViewController를 설정
    func start() {
        showLoadingScreen()
        fetchDataAndLoadMainScreen()
        bindWeatherViewController()
    }
    
    private func showLoadingScreen() {
          window.rootViewController = loadingViewController
          window.makeKeyAndVisible()
      }
    
    private func showMainScreen() {
        
         navigationController.setViewControllers([weatherViewController], animated: true)
         window.rootViewController = navigationController
     }
    
    private func fetchDataAndLoadMainScreen() {
            weatherViewController.viewModel.isLoading
                .skip(1)
                .distinctUntilChanged()
                .subscribe(onNext: { [weak self] isLoading in
                    print("isloading")
                    if !isLoading {
                        self?.loadingViewController.stopLoading()
                        self?.showMainScreen()
                    }
                })
                .disposed(by: disposeBag)
            
            weatherViewController.viewModel.bindInputToFetchWeather()
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
