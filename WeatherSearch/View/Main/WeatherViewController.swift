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
    
    //가장 큰 틀
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    init(viewModel: WeatherDataViewModel, searchVM: CitySearchViewModel) {
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
        bindWeatherViewModel()
        bindSearchBar()
        bindLoadingState()
        //bindCollectionViewData()
        navigationItem.hidesBackButton = true
    }
    
    private func bindCollectionViewData() {
           // 오늘의 도시 정보 데이터 바인딩
           viewModel.todayCityInfoData
               .compactMap { $0 }
               .asDriver(onErrorJustReturn: TodayCityInfoData(cityName: "", temperature: "", weatherStatue: "", tempMax: "", tempMin: ""))
               .drive(onNext: { [weak self] data in
                   guard let self = self, let cell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? CityTodayInfoCell else { return }
                   cell.configure(with: data)
               })
               .disposed(by: disposeBag)
           
           // 3시간 간격 날씨 데이터 바인딩
           viewModel.threeHourData
               .compactMap { $0 }
               .map { [$0] }
               .asDriver(onErrorJustReturn: [])
               .drive(collectionView.rx.items(cellIdentifier: "HourlyWeatherCell", cellType: HourlyWeatherCell.self)) { index, data, cell in
                   cell.configure(with: data)
               }
               .disposed(by: disposeBag)
           
           // 5일간 날씨 데이터 바인딩
           viewModel.dailyWeatherData
               .compactMap { $0 }
               .map { [$0] }
               .asDriver(onErrorJustReturn: [])
               .drive(collectionView.rx.items(cellIdentifier: "FiveDayInfoCell", cellType: FiveDayInfoCell.self)) { index, data, cell in
                   cell.configure(with: data)
               }
               .disposed(by: disposeBag)

           // 지도 좌표 데이터 바인딩
        viewModel.weatherData
            .compactMap { $0?.city.coord }
               .asDriver(onErrorJustReturn: Coord(lat: 0.0, lon: 0.0))
               .drive(onNext: { [weak self] coord in
                   guard let self = self, let cell = self.collectionView.cellForItem(at: IndexPath(item: 3, section: 0)) as? MapViewCell else { return }
                   cell.configure(with: coord)
               })
               .disposed(by: disposeBag)

           // 평균 데이터 (습도, 구름, 바람) 바인딩
           viewModel.averageData
               .compactMap { $0 }
               .asDriver(onErrorJustReturn: AverageWeatherData(humidity: "", clouds: "", windSpeed: ""))
               .drive(onNext: { [weak self] data in
                   guard let self = self, let cell = self.collectionView.cellForItem(at: IndexPath(item: 4, section: 0)) as? GridWeatherView else { return }
                   cell.configure(data: data)
               })
               .disposed(by: disposeBag)
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
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        // 셀 등록
        collectionView.register(CityTodayInfoCell.self, forCellWithReuseIdentifier: "CityTodayInfoCell")
        collectionView.register(HourlyWeatherCell.self, forCellWithReuseIdentifier: "HourlyWeatherCell")
        collectionView.register(FiveDayInfoCell.self, forCellWithReuseIdentifier: "FiveDayInfoCell")
        collectionView.register(MapViewCell.self, forCellWithReuseIdentifier: "MapViewCell")
        collectionView.register(GridWeatherView.self, forCellWithReuseIdentifier: "GridWeatherView")
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .bgColor
        
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
    
    private func bindWeatherViewModel() {
        // 검색 도시 weatherViewModel에 전달
        searchVM.searchCitySelected
            .bind(to: viewModel.searchCity)
            .disposed(by: disposeBag)
        
        // 뷰모델의 weatherData와 컬렉션뷰를 바인딩
        viewModel.weatherData
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.collectionView.reloadData()  // 데이터가 변경될 때 컬렉션뷰 업데이트
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
extension WeatherViewController: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //        return CGSize(width: collectionView.frame.width*0.9, height: 80)
        switch indexPath.item {
        case 0:
            return CGSize(width: collectionView.frame.width, height: 200) // City Info
        case 1:
            return CGSize(width: collectionView.frame.width, height: 150) // Hourly Weather
        case 2:
            return CGSize(width: collectionView.frame.width, height: 250) // MapView
        case 3:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.width) // Five Day Forecast
        case 4:
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.width) // Five Day Forecast
        default:
            return CGSize(width: collectionView.frame.width, height: 100)
        }
    }
}

extension WeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CityTodayInfoCell", for: indexPath) as! CityTodayInfoCell
            
            if let data = viewModel.todayCityInfoData.value {
                cell.configure(with: data)
            }
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyWeatherCell", for: indexPath) as! HourlyWeatherCell
            //이틀치의 데이터만 전달
            if let data = viewModel.threeHourData.value {
                print("데이터 전달")
                cell.configure(with: data)
            }
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FiveDayInfoCell", for: indexPath) as! FiveDayInfoCell
            if let data = viewModel.dailyWeatherData.value
            {
                cell.configure(with: data)
            }
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MapViewCell", for: indexPath) as! MapViewCell
            if let data = viewModel.weatherData.value {
                cell.configure(with: data.city.coord)
            }
            return cell
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridWeatherView", for: indexPath) as! GridWeatherView
            if let averageData = viewModel.averageData.value {
                cell.configure(data: averageData)
            }
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CityTodayInfoCell", for: indexPath) as! CityTodayInfoCell
            return cell
        }
    }
}
