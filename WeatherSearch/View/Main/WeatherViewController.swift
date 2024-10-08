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


final class WeatherViewController: UIViewController {
    
    let viewModel: WeatherViewModel
    private let disposeBag = DisposeBag()
    private let activityIndicator = UIActivityIndicatorView(style: .large) // 로딩 인디케이터
    
    private let searchBar = UISearchBar()
    private let containerView = UIView() // SearchBar 아래에 들어갈 컨테이너 뷰
    
    private let weatherContentView = UIView() // 기본 날씨 화면
    let searchBarTapped = PublishSubject<Void>()  // 검색바 클릭 이벤트

    //가장 큰 틀
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    // MapView
    let mapView = MKMapView()
    
    
    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
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
        bindErrorState()
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
    //검색 화면에서 선택된 도시를 처리하는 함수
    func selectedInSearchBar(with city: SearchCity) {
        print("weatherVC - 검색에서 도시 한개 선택 받음 \(city)")
        self.viewModel.searchCity.accept(city)
    }
    
    private func setupSearchBar() {
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    // 날씨 화면 표시
    private func showWeatherContent() {
        // 날씨 데이터를 보여줄 뷰 설정
        weatherContentView.backgroundColor = .bgColor
        containerView.addSubview(weatherContentView)
        weatherContentView.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
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
        collectionView.register(OtherInfoCell.self, forCellWithReuseIdentifier: "OtherInfoCell")
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .bgColor
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    private func bindErrorState(){
        // 에러 메시지를 UI에 표시
        viewModel.errorMessage
            .asDriver(onErrorJustReturn: "")
        // .drive(errorLabel.rx.text)
        // .disposed(by: disposeBag)
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
            return CGSize(width: collectionView.frame.width, height: 180) // Five Day Forecast
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
            
            if let data = viewModel.weatherData.value {
                cell.configure(with: data)
            }
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyWeatherCell", for: indexPath) as! HourlyWeatherCell
            //이틀치의 데이터만 전달
            if let data = viewModel.weatherData.value {
                print("데이터 전달")
              let sliced =  data.list.prefix(18)
                cell.configure(with: Array(sliced))
            }
            return cell
        case 2:
            //            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FiveDayInfoCell", for: indexPath) as! FiveDayInfoCell
            //            if let data = viewModel.weatherData.value {
            //                cell.configure(with: data.list)
            //            }
            //            return cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyWeatherCell", for: indexPath) as! HourlyWeatherCell
            
            if let data = viewModel.weatherData.value {
                print("데이터 전달")
                cell.configure(with: data.list)
            }
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MapViewCell", for: indexPath) as! MapViewCell
            return cell
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OtherInfoCell", for: indexPath) as! OtherInfoCell
            if let data = viewModel.weatherData.value {
                cell.configure(with: data.list)
            }
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CityTodayInfoCell", for: indexPath) as! CityTodayInfoCell
            return cell
        }
    }
}
