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
    private let pressureView = GridWeatherCellView(title: "", value: "")
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let firstRowStackView: UIStackView = {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .fill
        row.distribution = .fillEqually
        return row
    }()
    
    private let secondRowStackView: UIStackView = {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
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
        
        firstRowStackView.addArrangedSubview(humidityView)
        firstRowStackView.addArrangedSubview(cloudView)
        secondRowStackView.addArrangedSubview(windSpeedView)
        secondRowStackView.addArrangedSubview(pressureView)
        
        stackView.addArrangedSubview(firstRowStackView)
        stackView.addArrangedSubview(secondRowStackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(data: AverageWeatherData) {
        
        humidityView.setValue(data.humidity)
        cloudView.setValue(data.clouds)
        windSpeedView.setValue(data.windSpeed)
    }
}
