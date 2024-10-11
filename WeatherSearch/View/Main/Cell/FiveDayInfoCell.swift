//
//  FiveDayInfoCell.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/6/24.
//

import UIKit
import SnapKit

final class FiveDayInfoCell: UICollectionViewCell {
    
    //상단 타이틀
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "5일간의 일기예보"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.textColor = .white
        return label
    }()
    //전체 감싸는 스택
    private let stackView = UIStackView()
    var weatherData: [WeatherList] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setConstraints()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8
        contentView.addSubview(titleLabel)
        contentView.addSubview(stackView)
        
        contentView.backgroundColor = UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1) // 배경색
        contentView.layer.cornerRadius = 8
    }
    
    private func createWeatherView(day: String, icon: UIImage?, min: String, max: String) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        
        //요일
        let dayLabel = UILabel()
        dayLabel.text = day
        dayLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        dayLabel.textAlignment = .left
        dayLabel.textColor = .white
        
        //아이콘
        let iconImageView = UIImageView()
        iconImageView.image = icon
        iconImageView.contentMode = .scaleAspectFit
        // 최대 크기 설정
        iconImageView.snp.makeConstraints { make in
            make.width.height.lessThanOrEqualTo(30)
        }
        
        //최소, 최대
        let tempLabel = UILabel()
        tempLabel.text = "최소:\(min)°  최대:\(max)°"
        tempLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tempLabel.textAlignment = .right
        tempLabel.textColor = .white
        
        //stackview에 추가
        stackView.addArrangedSubview(dayLabel)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(tempLabel)
        
        return stackView
    }
    
    // 셀을 재사용하기 전에 상태 초기화
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//    }
    
    private func setConstraints() {
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            //make.height.equalTo(30)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16) // 타이틀 아래에 위치
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualToSuperview().offset(-16) // 너무 길어지지 않도록 설정
        }
    }
    
    func configure(with weatherData: [DailyWeatherData]) {
        // 기존 스택뷰의 모든 서브뷰 제거 (중복 추가 방지)
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                
        for i in 0..<5 {
            var day = ""
            if i == 0 {
                day = "오늘"
            }else{
                day = weatherData[i].dayOfWeek
            }
            let image = UIImage(named: weatherData[i].icon)
            let weatherView = createWeatherView(day:day, icon: image, min: String(Int(weatherData[i].tempMin)), max: String(Int(weatherData[i].tempMax)))
            stackView.addArrangedSubview(weatherView)
        }
    }
}
