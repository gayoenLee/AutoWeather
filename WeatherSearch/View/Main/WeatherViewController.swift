//
//  WeatherViewController.swift
//  YourWeather
//
//  Created by 이은호 on 10/4/24.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import MapKit

// 1. WeatherSection을 통해 섹션 구분
enum WeatherSection {
    case todayInfo
    case hourlyWeather
    case fiveDayInfo
    case mapView
    case gridWeather
}

final class WeatherViewController: UIViewController {
    //private let collectionBinder = CollectionBinder<WeatherModel>()

    let viewModel: WeatherDataViewModel
    let searchVM : CitySearchViewModel
    private let disposeBag = DisposeBag()
    private let weatherView = WeatherView()
    
    let searchBarTapped = PublishSubject<Void>()  // 검색바 클릭 이벤트
    let dataSource = WeatherCollectionViewDataSource()
    
    init(viewModel: WeatherDataViewModel, searchVM: CitySearchViewModel ) {
        self.viewModel = viewModel
        self.searchVM = searchVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationItem.hidesBackButton = true
        self.view.backgroundColor = .bgColor
        setupWeatherView()
        bindSearchBar()
        bindSearchSelected()
        bindLoadingState()
        bindWeatherDataVM()
        navigationItem.hidesBackButton = true
    }
    
    private func setupWeatherView() {
        self.view.addSubview(self.weatherView)
        //self.view.addSubview(weatherView)
        self.weatherView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.weatherView.delegate = dataSource
        self.weatherView.dataSource = dataSource
        // 데이터를 리로드하여 CollectionView를 업데이트
          weatherView.collectionView.reloadData()
    }
    
   
    private func bindSearchBar() {
        weatherView.searchBar.rx.textDidBeginEditing
            .bind(to: searchBarTapped)
            .disposed(by: disposeBag)
    }
    
    
    private func bindSearchSelected() {
        // 검색 도시 weatherViewModel에 전달
        searchVM.searchCitySelected
            .bind(to: viewModel.searchCity)
            .disposed(by: disposeBag)
    }
    
    private func bindWeatherDataVM(){
        
        // 검색 도시 weatherViewModel에 전달
        searchVM.searchCitySelected
            .bind(to: viewModel.searchCity)
            .disposed(by: disposeBag)
        
        // 오늘의 도시 정보 셀만 업데이트
        viewModel.fullWeatherData
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] weatherData in
                guard let self = self else { return }
  
                self.dataSource.update(with: weatherData)
                self.weatherView.collectionView.reloadData()
                
                
            })
            .disposed(by: disposeBag)
    }
    
    private func bindLoadingState() {
        // 로딩 상태를 UI에 반영
        viewModel.isLoading
            .asDriver()
            .drive(weatherView.activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
    }
}
