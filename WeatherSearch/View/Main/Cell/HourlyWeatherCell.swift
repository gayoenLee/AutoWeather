//
//  TwoDaysInfoCell.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/6/24.
//

import UIKit
import SnapKit


final class HourlyWeatherCell: UICollectionViewCell {
    
    // 상단 문장을 위한 UILabel
    private let windSpeedLabel: UILabel = {
        let label = UILabel()
        label.text = "2일간의 일기예보"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.textColor = .white
        return label
    }()
    
    // ScrollView로 감싸서 수평 스크롤이 가능하게 함
    private let scrollView = UIScrollView()
    
    // 수평 스크롤을 위한 StackView
    private let horizontalStackView = UIStackView()
    
    // 더미 데이터: 각 시간대의 날씨 정보를 보여줄 라벨들
    var hourlyWeatherData: [WeatherList] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // StackView 설정
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 16
        horizontalStackView.distribution = .fillEqually
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.addSubview(horizontalStackView)
        contentView.addSubview(windSpeedLabel)  // 상단 문장 추가
        contentView.addSubview(scrollView)      // 하단 스크롤 뷰 추가
        
        contentView.backgroundColor = .cellBgColor// 배경색
        contentView.layer.cornerRadius = 8
    }
    
    // 시간, 아이콘, 기온을 세로로 쌓는 StackView 생성
    private func createWeatherView(data: ThreeHourWeatherData) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        
        // 시간 라벨
        let timeLabel = UILabel()
        timeLabel.text = data.time
        timeLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        timeLabel.textAlignment = .left
        timeLabel.textColor = .white
        
        // 날씨 아이콘 이미지
        //let iconImageView = UIImageView()
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: data.iconName)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        
        // 기온 라벨
        let tempLabel = UILabel()
        tempLabel.text = "\(data.temperature)°"
        tempLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tempLabel.textAlignment = .center
        tempLabel.textColor = .white
        
        // 세로 StackView에 추가
        stackView.addArrangedSubview(timeLabel)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(tempLabel)
        
        return stackView
    }
    
    // 제약 조건 설정
    private func setupConstraints() {
        windSpeedLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(windSpeedLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview()
        }
        
        horizontalStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview() // 수평 스크롤이므로 높이는 고정
        }
    }
    
    // 데이터 설정 메서드
    func configure(with hourlyWeatherData: [ThreeHourWeatherData]) {
        // 기존 스택뷰의 모든 서브뷰 제거
           horizontalStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for data in hourlyWeatherData {
            let weatherView = createWeatherView(data: data)
            horizontalStackView.addArrangedSubview(weatherView)
        }
    }
}
