//
//  CustomCityCell.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/7/24.
//

import UIKit
import SnapKit

final class CustomCityCell: UITableViewCell {
    
    // 도시 이름 레이블
       private let cityLabel: UILabel = {
           let label = UILabel()
           label.font = UIFont.boldSystemFont(ofSize: 18)
           label.textColor = .white
           return label
       }()
       
       // 국가
       private let countryLabel: UILabel = {
           let label = UILabel()
           label.font = UIFont.systemFont(ofSize: 14)
           label.textColor = .lightGray
           return label
       }()
       
       override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
           super.init(style: style, reuseIdentifier: reuseIdentifier)
           setupView()
       }

       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
       
       private func setupView() {
           contentView.addSubview(cityLabel)
           contentView.addSubview(countryLabel)
           contentView.backgroundColor = .bgColor
           // SnapKit으로 레이아웃 설정
           cityLabel.snp.makeConstraints { make in
               make.leading.top.equalToSuperview().inset(16)
           }
           
           countryLabel.snp.makeConstraints { make in
               make.leading.equalTo(cityLabel)
               make.top.equalTo(cityLabel.snp.bottom).offset(4)
               make.bottom.equalToSuperview().inset(16)
           }
       }
       
       // 데이터를 설정하는 함수
       func configure(cityName: String, country: String) {
           cityLabel.text = cityName
           countryLabel.text = country
       }
   }
