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



class WeatherViewController: UIViewController {
      
    private let viewModel: WeatherViewModel
    private let disposeBag = DisposeBag()
    
    private let searchBar = UISearchBar()
    private let temperatureLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let searchButton = UIButton()

    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        setupSearchBar()
        setupTemperatureLabel()
        setupDescriptionLabel()
        setupSearchButton()
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "Search"
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func setupTemperatureLabel() {
        temperatureLabel.text = "온도"
        temperatureLabel.font = UIFont.systemFont(ofSize: 32)
        view.addSubview(temperatureLabel)
        temperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel.font = UIFont.systemFont(ofSize: 24)
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(temperatureLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupSearchButton() {
        searchButton.addTarget(self, action: #selector(navigateToSearch), for: .touchUpInside)
        view.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
        }
    }
    
    private func bindViewModel() {

    }
    
    @objc private func navigateToSearch() {
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }
}
