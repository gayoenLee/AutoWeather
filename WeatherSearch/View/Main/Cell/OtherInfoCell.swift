//
//  HumidityWithCloudCell.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/6/24.
//

import UIKit
import SnapKit


final class OtherInfoCell: UICollectionViewCell {
    
    // UIStackView를 사용한 그리드 레이아웃 설정
      private let verticalStackView = UIStackView()
      private let horizontalStackView1 = UIStackView()
      private let horizontalStackView2 = UIStackView()
      
      // 습도, 구름, 바람 속도에 대한 라벨 및 값 라벨
      private let humidityLabel = UILabel()
      private let cloudLabel = UILabel()
      private let windSpeedLabel = UILabel()
      // private let pressureLabel = UILabel() // 기압 항목 제거
      
      private let humidityValueLabel = UILabel()
      private let cloudValueLabel = UILabel()
      private let windSpeedValueLabel = UILabel()
      // private let pressureValueLabel = UILabel() // 기압 항목 제거
      
      override init(frame: CGRect) {
          super.init(frame: frame)
          setupView()
          setupConstraints()
      }

      required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
      
      private func setupView() {
          // 상위 수직 스택뷰 설정
          verticalStackView.axis = .vertical
          verticalStackView.alignment = .fill
          verticalStackView.distribution = .fillEqually
          verticalStackView.spacing = 8
          
          // 하위 수평 스택뷰 설정
          horizontalStackView1.axis = .horizontal
          horizontalStackView1.alignment = .fill
          horizontalStackView1.distribution = .fillEqually
          horizontalStackView1.spacing = 8
          
          horizontalStackView2.axis = .horizontal
          horizontalStackView2.alignment = .fill
          horizontalStackView2.distribution = .fillEqually
          horizontalStackView2.spacing = 8
          
          // 각각의 라벨 설정
          setupLabel(humidityLabel, text: "습도")
          setupLabel(cloudLabel, text: "구름")
          setupLabel(windSpeedLabel, text: "바람 속도")
          // setupLabel(pressureLabel, text: "기압") // 기압 항목 제거
          
          setupValueLabel(humidityValueLabel, text: "56%")
          setupValueLabel(cloudValueLabel, text: "50%")
          setupValueLabel(windSpeedValueLabel, text: "1.97m/s")
          // setupValueLabel(pressureValueLabel, text: "1,030 hpa") // 기압 항목 제거
          
          // 첫 번째 수평 스택뷰에 습도와 구름 추가
          horizontalStackView1.addArrangedSubview(createDataView(label: humidityLabel, valueLabel: humidityValueLabel))
          horizontalStackView1.addArrangedSubview(createDataView(label: cloudLabel, valueLabel: cloudValueLabel))
          
          // 두 번째 수평 스택뷰에 바람 속도만 추가
          horizontalStackView2.addArrangedSubview(createDataView(label: windSpeedLabel, valueLabel: windSpeedValueLabel))
          // 기압을 추가하지 않음
          
          // 수평 스택뷰들을 수직 스택뷰에 추가
          verticalStackView.addArrangedSubview(horizontalStackView1)
          verticalStackView.addArrangedSubview(horizontalStackView2)
          
          // contentView에 수직 스택뷰 추가
          contentView.addSubview(verticalStackView)
      }
      
      private func setupConstraints() {
          verticalStackView.snp.makeConstraints { make in
              make.edges.equalToSuperview().inset(8)
          }
      }
      
      // 라벨 스타일 설정
      private func setupLabel(_ label: UILabel, text: String) {
          label.text = text
          label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
          label.textAlignment = .center
          label.textColor = .white
      }
      
      // 값 라벨 스타일 설정
      private func setupValueLabel(_ label: UILabel, text: String) {
          label.text = text
          label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
          label.textAlignment = .center
          label.textColor = .white
      }
      
      // 라벨과 값이 쌍으로 들어가는 뷰 생성
      private func createDataView(label: UILabel, valueLabel: UILabel) -> UIStackView {
          let stackView = UIStackView()
          stackView.axis = .vertical
          stackView.alignment = .center
          stackView.spacing = 8
          stackView.addArrangedSubview(label)
          stackView.addArrangedSubview(valueLabel)
          return stackView
      }
      
      // 데이터를 업데이트하는 메서드 (기압 제거)
    func configure(with weatherDetails: [WeatherList]) {
        // humidityValueLabel.text = "\(weatherDetails.humidity)%"
        //          cloudValueLabel.text = "\(weatherDetails.cloud)%"
        //          windSpeedValueLabel.text = "\(weatherDetails.windSpeed)m/s"
        humidityValueLabel.text = "30%"
        cloudValueLabel.text = "55%"
        windSpeedValueLabel.text = "21m/s"
    }
  }
