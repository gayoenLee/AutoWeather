//
//  Date+.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/7/24.
//

import Foundation

extension Date {
    
    // UTC 시간을 한국 시간으로 변환하는 함수
    func toKoreanDayString() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // 변환된 UTC 시간을 로컬 시간으로 변환
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")!
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        dateFormatter.dateFormat = "EEEE"
        
        return dateFormatter.string(from: self)
    }
    
    // UTC 시간을 한국 시간으로 변환하는 함수
    func toKoreanTimeWithAMPM() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")!
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        dateFormatter.dateFormat = "a h시"
        
        return dateFormatter.string(from: self)
    }
    
    func getMinMaxTimeRange() -> (Date, Date)? {
        let calendar = Calendar.current
        
        // 현재 한국 시간 기준의 날짜
        var currentDate = Date()
        currentDate = calendar.date(bySetting: .minute, value: 0, of: currentDate) ?? currentDate
        currentDate = calendar.date(bySetting: .second, value: 0, of: currentDate) ?? currentDate
        
        // 최소 시간: 현재 시간 (한국 시간)
        let minDate = currentDate
        
        // 최대 시간: 현재 시간 + 48시간 (이틀 후)
        guard let maxDate = calendar.date(byAdding: .day, value: 2, to: minDate) else {
            return nil
        }
        
        return (minDate, maxDate)
    }
}

extension String {
    
    // ISO 8601 형식의 시간을 Date로 변환하고
    func convertISOStringToDate() -> Date? {
        
        let dateFormatter = DateFormatter()
        // 서버에서 받은 형식에 맞춘 포맷 설정 (ISO 형식이 아닌 일반 날짜 형식)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")  // 입력은 UTC 기준
        // 1. ISO 8601 형식 문자열을 Date로 변환
        guard let date = dateFormatter.date(from: self) else {
            return nil
        }
        return date
    }
}
