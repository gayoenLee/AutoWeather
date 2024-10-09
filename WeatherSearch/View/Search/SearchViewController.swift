//
//  SearchViewController.swift
//  YourWeather
//
//  Created by 이은호 on 10/5/24.
//

import SnapKit
import RxSwift
import RxCocoa
import UIKit

final class SearchViewController: UIViewController {
    
    let searchText = BehaviorRelay<String>(value: "")
    private let searchBar = UISearchBar()
   private let tableView = UITableView()
    private let viewModel: WeatherDataViewModel
    private let searchVM: CitySearchViewModel
       private let disposeBag = DisposeBag()
     var didSelectCity = PublishSubject<SearchCity>()
    
    
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
           searchVM.loadCityData()
           setupUI()
           setupConstraints()
           bindTableView()
           setupKeyboardNotification()  // 키보드 노티피케이션 설정
           bindSearchBar()

       }
    
    private func setupUI() {
            // 검색바 설정
            view.addSubview(searchBar)
            view.addSubview(tableView)
            tableView.backgroundColor = .bgColor
            tableView.register(CustomCityCell.self, forCellReuseIdentifier: "CustomCityCell")
            
    }
    
    
    private func setupConstraints() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
      
        tableView.snp.makeConstraints { make in
                 make.top.equalTo(searchBar.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()          // 테이블 뷰가 화면의 좌우에 맞도록 설정
                make.bottom.equalTo(view.safeAreaLayoutGuide)                }
     }
    
    // 키보드 노티피케이션 설정
    private func setupKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func bindSearchBar() {
        // 검색어에 따른 필터링 로직
        searchBar.rx.text.orEmpty
                 .distinctUntilChanged()
                 .flatMapLatest { query -> Observable<[CityDataList]> in
                     if query.isEmpty {
                         return Observable.just(self.searchVM.allCities.value)  // 검색어가 없을 때 전체 도시 반환
                     } else {
                         let filtered = self.searchVM.allCities.value.filter { $0.name.lowercased().contains(query.lowercased()) }
                         return Observable.just(filtered)
                     }
                 }
                 .bind(to: searchVM.filteredCities)
                 .disposed(by: disposeBag)
    }
        
    // ViewModel과의 바인딩 설정
    private func bindTableView() {
        
        // 테이블뷰의 선택 이벤트 처리
        tableView.rx.modelSelected(CityDataList.self)
            .map { data in
                print("테이블뷰에서 1개 선택: \(data)")
                let result = SearchCity(cityName: data.name, lat: String(data.coord.lat), lon: String(data.coord.lon))
                return result
            }
            .subscribe(onNext: { [weak self] city in
                guard let self = self else { return }
                print("주려는 데이터: \(city)")
                self.viewModel.searchCity.accept(city)
                print("구독 후 전달된 값: \(city)")
            })
            .disposed(by: disposeBag)
        
        // ViewModel에서 필터링된 도시 리스트를 테이블뷰에 바인딩
        searchVM.filteredCities
            .distinctUntilChanged()
            .bind(to: tableView.rx.items(cellIdentifier: "CustomCityCell", cellType: CustomCityCell.self)) { index, city, cell in
                cell.configure(cityName: city.name, country: city.country)
            }
              .disposed(by: disposeBag)
        }
    
    // 키보드가 나타날 때 호출되는 메서드
     @objc private func keyboardWillShow(notification: NSNotification) {
         if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
             let keyboardHeight = keyboardFrame.cgRectValue.height
             // 테이블뷰의 bottom inset을 키보드 높이만큼 설정
             tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
         }
     }
    
    // 키보드가 사라질 때 호출되는 메서드
      @objc private func keyboardWillHide(notification: NSNotification) {
          // 테이블뷰의 bottom inset을 0으로 설정
          tableView.contentInset = .zero
      }
      
}

