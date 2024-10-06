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


class WeatherViewController: UIViewController {
    
    private let viewModel: WeatherViewModel
    private let disposeBag = DisposeBag()
    
    private let searchBar = UISearchBar()
    
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
        setupCollectionView()
        //bindViewModel()
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
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
            
        }
        
        //        setupSearchBar()
        //        setupTemperatureLabel()
        //        setupDescriptionLabel()
        // setupSearchButton()
        
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "Search"
        searchBar.backgroundImage = UIImage()
        searchBar.isTranslucent = true
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .clear // 검색 필드 배경 투명하게 설정
            textField.layer.backgroundColor = UIColor.txtFieldColor?.cgColor
            textField.layer.cornerRadius = 20
            textField.layer.masksToBounds = true
        }
    }
    
    //
    //    private func setupFirstSection() {
    //        let firstSection = UIView()
    //
    //        firstSection.addSubview(todayWeatherInfoCell)
    //        stackView.addArrangedSubview(firstSection)
    //        firstSection.snp.makeConstraints { make in
    //            make.height.equalTo(250)
    //        }
    //    }
    //
    //    private func setupSecondSection() {
    //        let secondSection = UIView()
    //        secondSection.addSubview(hourlyWeatherCollectionView)
    //        stackView.addArrangedSubview(secondSection)
    //        secondSection.snp.makeConstraints { make in
    //            make.height.equalTo(100)
    //        }
    
    //}
    
    
    //이거 나중에 검색바 클릭하면 작동되도록 해야함.
    //    private func setupSearchButton() {
    //        searchButton.addTarget(self, action: #selector(navigateToSearch), for: .touchUpInside)
    //        view.addSubview(searchButton)
    //        searchButton.snp.makeConstraints { make in
    //            make.top.equalTo(descriptionLabel.snp.bottom).offset(32)
    //            make.centerX.equalToSuperview()
    //        }
    //    }
    
    private func bindViewModel() {
        
    }
    //
    //    @objc private func navigateToSearch() {
    //        let searchVC = SearchViewController()
    //        navigationController?.pushViewController(searchVC, animated: true)
    //    }
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
            let weatherModel = WeatherModel(
                cod: "200",
                message: 0,
                cnt: 1,
                weatherList: [WeatherList(
                    dt: 123456789,
                    main: Main(temp: 20.0, feelsLike: 19.0, tempMin: 18.0, tempMax: 22.0, pressure: 1013, seaLevel: 1013, grndLevel: 1013, humidity: 75, tempKf: 0),
                    weather: [Weather(id: 1, main: "Clear", description: "맑음", icon: "01d")],
                    clouds: Clouds(all: 0),
                    wind: Wind(speed: 3.0, deg: 150, gust: 4.0),
                    visibility: 10000,
                    pop: 0,
                    rain: nil,
                    sys: Sys(pod: "d"),
                    dtTxt: "2024-10-06 15:00:00"
                )],
                cityInfo: City(id: 1, name: "Seoul", coord: Coord(lat: 37.5665, lon: 126.9780), country: "KR", population: 1000000, timezone: 32400, sunrise: 1600000000, sunset: 1600050000))
            cell.configure(with: weatherModel)
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyWeatherCell", for: indexPath) as! HourlyWeatherCell
            let weatherModel = [WeatherList(
                dt: 123456789,
                main: Main(temp: 20.0, feelsLike: 19.0, tempMin: 18.0, tempMax: 22.0, pressure: 1013, seaLevel: 1013, grndLevel: 1013, humidity: 75, tempKf: 0),
                weather: [Weather(id: 1, main: "Clear", description: "맑음", icon: "01d")],
                clouds: Clouds(all: 0),
                wind: Wind(speed: 3.0, deg: 150, gust: 4.0),
                visibility: 10000,
                pop: 0,
                rain: nil,
                sys: Sys(pod: "d"),
                dtTxt: "2024-10-06 15:00:00"
            ), WeatherList(
                dt: 123456789,
                main: Main(temp: 20.0, feelsLike: 19.0, tempMin: 18.0, tempMax: 22.0, pressure: 1013, seaLevel: 1013, grndLevel: 1013, humidity: 75, tempKf: 0),
                weather: [Weather(id: 1, main: "Clear", description: "맑음", icon: "01d")],
                clouds: Clouds(all: 0),
                wind: Wind(speed: 3.0, deg: 150, gust: 4.0),
                visibility: 10000,
                pop: 0,
                rain: nil,
                sys: Sys(pod: "d"),
                dtTxt: "2024-10-06 15:00:00"
            ),WeatherList(
                dt: 123456789,
                main: Main(temp: 20.0, feelsLike: 19.0, tempMin: 18.0, tempMax: 22.0, pressure: 1013, seaLevel: 1013, grndLevel: 1013, humidity: 75, tempKf: 0),
                weather: [Weather(id: 1, main: "Clear", description: "맑음", icon: "01d")],
                clouds: Clouds(all: 0),
                wind: Wind(speed: 3.0, deg: 150, gust: 4.0),
                visibility: 10000,
                pop: 0,
                rain: nil,
                sys: Sys(pod: "d"),
                dtTxt: "2024-10-06 15:00:00"
            ),WeatherList(
                dt: 123456789,
                main: Main(temp: 20.0, feelsLike: 19.0, tempMin: 18.0, tempMax: 22.0, pressure: 1013, seaLevel: 1013, grndLevel: 1013, humidity: 75, tempKf: 0),
                weather: [Weather(id: 1, main: "Clear", description: "맑음", icon: "01d")],
                clouds: Clouds(all: 0),
                wind: Wind(speed: 3.0, deg: 150, gust: 4.0),
                visibility: 10000,
                pop: 0,
                rain: nil,
                sys: Sys(pod: "d"),
                dtTxt: "2024-10-06 15:00:00"
            ),WeatherList(
                dt: 123456789,
                main: Main(temp: 20.0, feelsLike: 19.0, tempMin: 18.0, tempMax: 22.0, pressure: 1013, seaLevel: 1013, grndLevel: 1013, humidity: 75, tempKf: 0),
                weather: [Weather(id: 1, main: "Clear", description: "맑음", icon: "01d")],
                clouds: Clouds(all: 0),
                wind: Wind(speed: 3.0, deg: 150, gust: 4.0),
                visibility: 10000,
                pop: 0,
                rain: nil,
                sys: Sys(pod: "d"),
                dtTxt: "2024-10-06 15:00:00"
            )]
            cell.configure(with: weatherModel)
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FiveDayInfoCell", for: indexPath) as! FiveDayInfoCell
            let weatherModel = [WeatherList(
                dt: 123456789,
                main: Main(temp: 20.0, feelsLike: 19.0, tempMin: 18.0, tempMax: 22.0, pressure: 1013, seaLevel: 1013, grndLevel: 1013, humidity: 75, tempKf: 0),
                weather: [Weather(id: 1, main: "Clear", description: "맑음", icon: "01d")],
                clouds: Clouds(all: 0),
                wind: Wind(speed: 3.0, deg: 150, gust: 4.0),
                visibility: 10000,
                pop: 0,
                rain: nil,
                sys: Sys(pod: "d"),
                dtTxt: "2024-10-06 15:00:00"
            ), WeatherList(
                dt: 123456789,
                main: Main(temp: 20.0, feelsLike: 19.0, tempMin: 18.0, tempMax: 22.0, pressure: 1013, seaLevel: 1013, grndLevel: 1013, humidity: 75, tempKf: 0),
                weather: [Weather(id: 1, main: "Clear", description: "맑음", icon: "01d")],
                clouds: Clouds(all: 0),
                wind: Wind(speed: 3.0, deg: 150, gust: 4.0),
                visibility: 10000,
                pop: 0,
                rain: nil,
                sys: Sys(pod: "d"),
                dtTxt: "2024-10-06 15:00:00"
            ),WeatherList(
                dt: 123456789,
                main: Main(temp: 20.0, feelsLike: 19.0, tempMin: 18.0, tempMax: 22.0, pressure: 1013, seaLevel: 1013, grndLevel: 1013, humidity: 75, tempKf: 0),
                weather: [Weather(id: 1, main: "Clear", description: "맑음", icon: "01d")],
                clouds: Clouds(all: 0),
                wind: Wind(speed: 3.0, deg: 150, gust: 4.0),
                visibility: 10000,
                pop: 0,
                rain: nil,
                sys: Sys(pod: "d"),
                dtTxt: "2024-10-06 15:00:00"
            ),WeatherList(
                dt: 123456789,
                main: Main(temp: 20.0, feelsLike: 19.0, tempMin: 18.0, tempMax: 22.0, pressure: 1013, seaLevel: 1013, grndLevel: 1013, humidity: 75, tempKf: 0),
                weather: [Weather(id: 1, main: "Clear", description: "맑음", icon: "01d")],
                clouds: Clouds(all: 0),
                wind: Wind(speed: 3.0, deg: 150, gust: 4.0),
                visibility: 10000,
                pop: 0,
                rain: nil,
                sys: Sys(pod: "d"),
                dtTxt: "2024-10-06 15:00:00"
            ),WeatherList(
                dt: 123456789,
                main: Main(temp: 20.0, feelsLike: 19.0, tempMin: 18.0, tempMax: 22.0, pressure: 1013, seaLevel: 1013, grndLevel: 1013, humidity: 75, tempKf: 0),
                weather: [Weather(id: 1, main: "Clear", description: "맑음", icon: "01d")],
                clouds: Clouds(all: 0),
                wind: Wind(speed: 3.0, deg: 150, gust: 4.0),
                visibility: 10000,
                pop: 0,
                rain: nil,
                sys: Sys(pod: "d"),
                dtTxt: "2024-10-06 15:00:00"
            )]
            cell.configure(with: weatherModel)
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MapViewCell", for: indexPath) as! MapViewCell
            return cell
        case 4:
            
            let weatherModel = [WeatherList(
                dt: 123456789,
                main: Main(temp: 20.0, feelsLike: 19.0, tempMin: 18.0, tempMax: 22.0, pressure: 1013, seaLevel: 1013, grndLevel: 1013, humidity: 75, tempKf: 0),
                weather: [Weather(id: 1, main: "Clear", description: "맑음", icon: "01d")],
                clouds: Clouds(all: 0),
                wind: Wind(speed: 3.0, deg: 150, gust: 4.0),
                visibility: 10000,
                pop: 0,
                rain: nil,
                sys: Sys(pod: "d"),
                dtTxt: "2024-10-06 15:00:00"
            ), WeatherList(
                dt: 123456789,
                main: Main(temp: 20.0, feelsLike: 19.0, tempMin: 18.0, tempMax: 22.0, pressure: 1013, seaLevel: 1013, grndLevel: 1013, humidity: 75, tempKf: 0),
                weather: [Weather(id: 1, main: "Clear", description: "맑음", icon: "01d")],
                clouds: Clouds(all: 0),
                wind: Wind(speed: 3.0, deg: 150, gust: 4.0),
                visibility: 10000,
                pop: 0,
                rain: nil,
                sys: Sys(pod: "d"),
                dtTxt: "2024-10-06 15:00:00"
            ),WeatherList(
                dt: 123456789,
                main: Main(temp: 20.0, feelsLike: 19.0, tempMin: 18.0, tempMax: 22.0, pressure: 1013, seaLevel: 1013, grndLevel: 1013, humidity: 75, tempKf: 0),
                weather: [Weather(id: 1, main: "Clear", description: "맑음", icon: "01d")],
                clouds: Clouds(all: 0),
                wind: Wind(speed: 3.0, deg: 150, gust: 4.0),
                visibility: 10000,
                pop: 0,
                rain: nil,
                sys: Sys(pod: "d"),
                dtTxt: "2024-10-06 15:00:00"
            ),WeatherList(
                dt: 123456789,
                main: Main(temp: 20.0, feelsLike: 19.0, tempMin: 18.0, tempMax: 22.0, pressure: 1013, seaLevel: 1013, grndLevel: 1013, humidity: 75, tempKf: 0),
                weather: [Weather(id: 1, main: "Clear", description: "맑음", icon: "01d")],
                clouds: Clouds(all: 0),
                wind: Wind(speed: 3.0, deg: 150, gust: 4.0),
                visibility: 10000,
                pop: 0,
                rain: nil,
                sys: Sys(pod: "d"),
                dtTxt: "2024-10-06 15:00:00"
            ),WeatherList(
                dt: 123456789,
                main: Main(temp: 20.0, feelsLike: 19.0, tempMin: 18.0, tempMax: 22.0, pressure: 1013, seaLevel: 1013, grndLevel: 1013, humidity: 75, tempKf: 0),
                weather: [Weather(id: 1, main: "Clear", description: "맑음", icon: "01d")],
                clouds: Clouds(all: 0),
                wind: Wind(speed: 3.0, deg: 150, gust: 4.0),
                visibility: 10000,
                pop: 0,
                rain: nil,
                sys: Sys(pod: "d"),
                dtTxt: "2024-10-06 15:00:00"
            )]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OtherInfoCell", for: indexPath) as! OtherInfoCell
            cell.configure(with: weatherModel)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CityTodayInfoCell", for: indexPath) as! CityTodayInfoCell
            return cell
        }
    }
}
//        switch viewModel.sections {
//        case .today:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CityTodayInfoCell", for: indexPath) as! CityTodayInfoCell
//            cell.configure(with: WeatherModel(cod: "200", message: 0, cnt: 40, weatherList: [WeatherList(dt: 1661871600, main: Main(temp: 296.76, feelsLike: 296.98, tempMin: 296.76, tempMax: 297.87, pressure: 1015, seaLevel: 1015, grndLevel: 933, humidity: 69, tempKf: -1.11), weather: [Weather(id: 500, main: "Rain", description: "light ratin", icon: "10d")], clouds: Clouds(all: 100), wind: Wind(speed: 0.62, deg: 349, gust: 1.18), visibility: 10000, pop: 0.32, rain: nil, sys: Sys(pod: "d"), dtTxt: "2022-08-30 15:00:00")], cityInfo: City(id: 3163858, name: "Zocca", coord: Coord(lat: 44.34, lon: 10.99), country: "IT", population: 4593, timezone: 7200, sunrise: 1661834187, sunset: 1661882248)))
//            return cell
//        case .twoDays:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyWeatherCell", for: indexPath) as! HourlyWeatherCell
//            cell.configure(with: [HourlyWeatherModel(time: "20:00", temperature: "328")])
//            return cell
//        case .fiveDays:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyWeatherCell", for: indexPath) as! HourlyWeatherCell
//            return cell
//        case .location:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentLocationCell", for: indexPath) as! CurrentLocationCell
//            return cell
//        case .WindSpeed:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentLocationCell", for: indexPath) as! CurrentLocationCell
//            return cell
//        case .humidityWithCloud:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentLocationCell", for: indexPath) as! CurrentLocationCell
//            return cell
//        }
