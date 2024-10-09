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
    private let collectionBinder = CollectionBinder<WeatherModel>()

    let viewModel: WeatherDataViewModel
    let searchVM : CitySearchViewModel
    private let disposeBag = DisposeBag()
    private let activityIndicator = UIActivityIndicatorView(style: .large) // 로딩 인디케이터
    
    private let searchBar = UISearchBar()
    private let containerView = UIView() // SearchBar 아래에 들어갈 컨테이너 뷰
    
    let searchBarTapped = PublishSubject<Void>()  // 검색바 클릭 이벤트
    let dataSource = WeatherCollectionViewDataSource()
    //가장 큰 틀
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
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
        setupSearchBar()
        setupContainerView()
        setupCollectionView()
        setupIndicator()
    
        bindSearchBar()
        bindSearchSelected()
        bindLoadingState()
        bindWeatherDataVM()
        navigationItem.hidesBackButton = true
    }
    
   
    private func bindSearchBar() {
        searchBar.rx.textDidBeginEditing
            .bind(to: searchBarTapped)
            .disposed(by: disposeBag)
    }
    
    // ContainerView 설정 (SearchBar 아래 뷰들만 교체)
    private func setupContainerView() {
        view.addSubview(containerView)
        containerView.backgroundColor = .bgColor
        containerView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)  // 안전영역까지 containerView가 확장되도록 수정
        }
    }

    private func setupSearchBar() {
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func setupCollectionView() {
        collectionView = WeatherViewFactory.createCollectionView()
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        
        containerView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()  // containerView 내에서 꽉 차도록 설정
        }
    }

    
    private func setupIndicator(){
        // 로딩 인디케이터
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
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
                collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindLoadingState() {
        // 로딩 상태를 UI에 반영
        viewModel.isLoading
            .asDriver()
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
    }
}
