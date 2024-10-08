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
    private let title: UILabel = {
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
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(title)
    }
    
    private func createWeatherView(day: String, icon: UIImage?, min: String, max: String) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 10
        
        //요일
        let dayLabel = UILabel()
        dayLabel.text = day
        dayLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        dayLabel.textAlignment = .left
        
        //아이콘
        let iconImageView = UIImageView()
        iconImageView.image = icon
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
     
        //최소, 최대
        let tempLabel = UILabel()
        tempLabel.text = "최소:\(min) 최대:\(max)"
        tempLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tempLabel.textAlignment = .right
        
        //stackview에 추가
        stackView.addArrangedSubview(dayLabel)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(tempLabel)
        
        return stackView
    }
    
    private func setConstraints() {
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }
    
    func configure(with weatherData: [(dayOfWeek: String, tempMax: Double, tempMin: Double, weatherIcon: String)]) {
        // 기존 스택뷰의 모든 서브뷰 제거 (중복 추가 방지)
             stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
             
             // 타이틀 다시 추가
             stackView.addArrangedSubview(title)
             
        for i in 0..<5 {
            var day = ""
            if i == 0 {
                day = "오늘"
            }else{
                day = weatherData[i].dayOfWeek
            }
            let image = UIImage(named: weatherData[i].weatherIcon)
            let weatherView = createWeatherView(day:day, icon: image, min: String(weatherData[i].tempMin), max: String(weatherData[i].tempMax))
                 stackView.addArrangedSubview(weatherView)
             }
         }
}
