//
//  GridWeatherCellView.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/8/24.
//

import Foundation
import UIKit
import SnapKit

final class GridWeatherCellView: UIView {
    
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
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .center
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        // 스타일 설정
        backgroundColor = UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1)
        layer.cornerRadius = 8
        clipsToBounds = true
    }
    
    func setValue(_ value: String) {
        valueLabel.text = value
    }
}
