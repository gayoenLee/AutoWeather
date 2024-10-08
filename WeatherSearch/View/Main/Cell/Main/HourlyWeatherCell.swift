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
        label.text = "돌풍의 풍속은 최대 4m/s입니다."
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
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
    }
    
    // 시간, 아이콘, 기온을 세로로 쌓는 StackView 생성
    private func createWeatherView(time: String, icon: UIImage?, temperature: String) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        
        // 시간 라벨
        let timeLabel = UILabel()
        timeLabel.text = time
        timeLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        timeLabel.textAlignment = .left
        
        // 날씨 아이콘 이미지
        //let iconImageView = UIImageView()
        let iconImageView = UIImageView()
        iconImageView.image = icon
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        
        // 기온 라벨
        let tempLabel = UILabel()
        tempLabel.text = temperature
        tempLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tempLabel.textAlignment = .center
        
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
    func configure(with hourlyWeatherData: [WeatherList]) {
        self.hourlyWeatherData = hourlyWeatherData
        let s = hourlyWeatherData.map({ $0.dtTxt})
        let data = filterData()
  
        var labelTxt = ""
        guard let data = data else { return }
        for (idx,weather) in data.enumerated() {
            if idx == 0 {
                labelTxt = "지금"
            }else{
                labelTxt = convertTimeToLabel(time: weather.dtTxt)
            }
            let temperature = String(weather.main.temp)
            let iconName = getWeatherIcon(id: weather.weather[0].id)
            let weatherView = createWeatherView(time: labelTxt, icon: UIImage(named: iconName), temperature: "\(temperature)°")
            horizontalStackView.addArrangedSubview(weatherView)
        }
    }
    
    private func filterData() -> [WeatherList]? {
        // 현재 한국 시간을 구함
        let currentDate = Date()
        print("현재 한국 시간: \(currentDate)")
        let convertedData = currentDate.toUTC()
        if let minDate = convertedData.0, let minHour = convertedData.1{
            print("최소: \(minDate), 시각만: \(minHour)") // 시간만(hour) 가져와서 비교
            
            let maxTime = minDate.addOneDay()!
            print("최대: \(maxTime)")
            
                let filteredData = self.hourlyWeatherData.compactMap({ weather in
                if let val = weather.dtTxt.isoStringToDate(dateString: weather.dtTxt) {
                    if minHour <= val && val <= maxTime {
                        return weather
                    }
                }
                return nil
            })
            return filteredData
        }
        return nil
    }
       
    private func convertTimeToLabel(time: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a h시"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        // Unix 타임스탬프를 사용하여 Date 객체 생성
        return time.convertISOToKoreanTime(isoString: time)
    }
    
    private func getWeatherIcon(id: Int) -> String {
        switch id {
        case 200...232:
            return "11d"
        case 300...321:
            return "09d"
        case 500...504:
            return "10d"
        case 511:
            return "13d"
        case 520...531:
            return "09d"
        case 600...622:
            return "13d"
        case 701...781:
            return "50d"
        case 800:
            return "01d"
        case 801:
            return "02d"
        case 802:
            return "03d"
        case 803...804:
            return "04d"
        default:
            return "알 수 없음"
        }
    }
}
