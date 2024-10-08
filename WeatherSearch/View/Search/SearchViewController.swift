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
    
    private let searchBar = UISearchBar()
   private let tableView = UITableView()
    private let viewModel: WeatherViewModel
       private let disposeBag = DisposeBag()
     var didSelectCity = PublishSubject<SearchCity>()
    
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
           viewModel.loadCityData()
           setupUI()
           setupConstraints()
           bindTableView()
           setupKeyboardNotification()  // 키보드 노티피케이션 설정

       }
    
    private func setupUI() {
            // 검색바 설정
            view.addSubview(searchBar)
            view.addSubview(tableView)
            tableView.backgroundColor = .bgColor
            tableView.register(CustomCityCell.self, forCellReuseIdentifier: "CustomCityCell")
        
        /*
         // 검색바를 위로 이동시키는 애니메이션
//            self.searchBar.snp.updateConstraints { make in
//                make.top.equalTo(self.view.safeAreaLayoutGuide).offset(-30) // 적절한 위치로 이동
//            }
         */
            
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
                self.didSelectCity.onNext(city)
                print("구독 후 전달된 값: \(city)")
            })
            .disposed(by: disposeBag)
        
        // ViewModel에서 필터링된 도시 리스트를 테이블뷰에 바인딩
          viewModel.filteredCities
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

