//
//  GridWeatherCellView.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/8/24.
//

import Foundation
import UIKit
import SnapKit

final class GridWeatherCellView: UICollectionViewCell {
    
       private let titleLabel = UILabel()
       private let valueLabel = UILabel()
    
       init(title: String, value: String) {
           super.init(frame: .zero)
           setupView(title: title, value: value)
       }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
       
       private func setupView(title: String, value: String) {
           // 타이틀 설정
                 titleLabel.text = title
                 titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                 titleLabel.textColor = .white
                 titleLabel.textAlignment = .center
                 
                 // 값 설정
                 valueLabel.text = value
                 valueLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
                 valueLabel.textColor = .white
                 valueLabel.textAlignment = .center
           // 스택뷰로 두 라벨을 정렬
             let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
             stackView.axis = .vertical
             stackView.alignment = .center
             stackView.distribution = .fillProportionally
             addSubview(stackView)
             
             // 제약 조건 설정
             stackView.snp.makeConstraints { make in
                 make.edges.equalToSuperview().inset(8)
             }
           
           self.backgroundColor = UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1) // 배경색
           self.layer.cornerRadius = 8
       }
    func setValue(_ value: String) {
           valueLabel.text = value
       }
}
