//
//  GridWeatherView.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/8/24.
//

import Foundation
import UIKit
import SnapKit

final class GridWeatherView: UICollectionViewCell {
    
    private let humidityView = GridWeatherCellView(title: "습도", value: "%")
    private let cloudView = GridWeatherCellView(title: "구름", value: "")
    private let windSpeedView = GridWeatherCellView(title: "바람 속도", value: "")
    private let pressureView = GridWeatherCellView(title: "기압", value: "")
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let firstRowStackView: UIStackView = {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 16
        row.alignment = .fill
        row.distribution = .fillEqually
        return row
    }()
    
    private let secondRowStackView: UIStackView = {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 16
        row.alignment = .fill
        row.distribution = .fillEqually
        return row
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    
      required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
      
    
    private func setupView() {
        addSubview(stackView)
              
              // Add two rows to stackView
              firstRowStackView.addArrangedSubview(humidityView)
              firstRowStackView.addArrangedSubview(cloudView)
              secondRowStackView.addArrangedSubview(windSpeedView)
              secondRowStackView.addArrangedSubview(pressureView)
              
              stackView.addArrangedSubview(firstRowStackView)
              stackView.addArrangedSubview(secondRowStackView)
              
              stackView.snp.makeConstraints { make in
                  make.edges.equalToSuperview().inset(16)
              }
          }
    
    func configure(humidity: String, clouds: String, windSpeed: String) {
                humidityView.setValue(humidity)
              cloudView.setValue(clouds)
              windSpeedView.setValue(windSpeed)
    }
    
    
}
