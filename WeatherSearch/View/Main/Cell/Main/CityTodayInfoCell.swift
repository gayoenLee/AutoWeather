//
//  CityCurrentInfoCell.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/5/24.
//

import UIKit
import SnapKit


final class CityTodayInfoCell: UICollectionViewCell {
    
    // UI 요소 정의
    let stackView = UIStackView()
   private let cityLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let weatherDescriptionLabel = UILabel()
    private let highLowLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        
        setupCityLabel()
        setupTempLabel()
        setupWeatherDescriptionLabel()
        setupHighLowLabel()
        
        contentView.addSubview(stackView)
        setupConstraints()
    }
    
    private func setupCityLabel() {
        self.cityLabel.text = "Seoul"
        cityLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        cityLabel.textColor = .white
        cityLabel.textAlignment = .center
        
        stackView.addArrangedSubview(cityLabel)
    }
    
    private func setupTempLabel() {
        // 현재 기온 라벨 설정
        temperatureLabel.text = "-7°"
        temperatureLabel.font = UIFont.systemFont(ofSize: 60, weight: .thin)
        temperatureLabel.textColor = .white
        temperatureLabel.textAlignment = .center
        
        stackView.addArrangedSubview(temperatureLabel)

    }
    
    private func setupWeatherDescriptionLabel() {
        // 날씨 설명 라벨 설정
        weatherDescriptionLabel.text = "맑음"
        weatherDescriptionLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        weatherDescriptionLabel.textColor = .white
        weatherDescriptionLabel.textAlignment = .center
        
        stackView.addArrangedSubview(weatherDescriptionLabel)

    }
    
    private func setupHighLowLabel() {
        // 최고/최저 기온 라벨 설정
        highLowLabel.text = "최고: -1° | 최저: -11°"
        highLowLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        highLowLabel.textColor = UIColor.black.withAlphaComponent(0.8)
        highLowLabel.textAlignment = .center
        
        stackView.addArrangedSubview(highLowLabel)
    }
    

    // 레이아웃 제약 설정 (SnapKit 사용)
    private func setupConstraints() {
        // StackView 제약 조건 설정
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
            }
        stackView.backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    // 데이터를 설정하는 함수
    func configure(with model: WeatherModel) {
        let recentData = model.list[0]
        cityLabel.text = model.city.name
        let temperature = String(recentData.main.temp)
        temperatureLabel.text = "\(temperature)°"
        let condition = String(recentData.weather[0].koreanDescription)
        print("날씨 바꾼 것 확인: \(condition)")
        weatherDescriptionLabel.text = condition
        let high = Int(recentData.main.tempMax)
        let low = Int(recentData.main.tempMin)
        highLowLabel.text = "최고: \(high)° | 최저: \(low)°"
    }
}
