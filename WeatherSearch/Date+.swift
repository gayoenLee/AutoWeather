//
//  Date+.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/7/24.
//

import Foundation

extension Date {
    func getCurrentDate() -> String {
            let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
            return dateFormatter.string(from: self)
        }
    
    // 한국 시간을 UTC로 변환하는 함수
    func toUTC() -> (Date?,Date?) {
        // 한국 시간대 설정된 Calendar 사용
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "KST")!  // 한국 시간대 설정
        calendar.locale = Locale(identifier: "ko_KR")
        // 현재 시간을 UTC 시간대로 변환
        let utcTimeZone = TimeZone(identifier: "UTC")!
        let utcDate = calendar.date(from: calendar.dateComponents(in: utcTimeZone, from: self))
        
        // UTC로 변환된 시간에서 시각만 추출
           guard let date = utcDate else { return (nil,nil) }
        // 현재 날짜의 시, 분, 초만 추출하여 Date로 변환
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        var zeroedComponents = DateComponents()
               zeroedComponents.year = components.year
               zeroedComponents.month = components.month
               zeroedComponents.day = components.day
               zeroedComponents.hour = components.hour
               zeroedComponents.minute = 0
               zeroedComponents.second = 0
               
               
            // 변환된 시각만을 포함한 Date 생성
            let utcHourDate = calendar.date(from: zeroedComponents)
        
        return (utcDate,utcHourDate)
    }
    
    // UTC 시간을 한국 시간으로 변환하는 함수 (반대 기능)
    func toKoreanTime() -> Date? {
        let koreanTimeZone = TimeZone(abbreviation: "KST")!
        var calendar = Calendar.current
        calendar.timeZone = koreanTimeZone
        let koreanDate = calendar.date(from: calendar.dateComponents(in: koreanTimeZone, from: self))
        return koreanDate
    }
    
    // 변환된 UTC 시간에 하루 더한 값 계산
    func addOneDay() -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!  // UTC 시간대 설정
        return calendar.date(byAdding: .day, value: 1, to: self)  // 하루 더하기
    }
    
    // 날짜에 맞는 요일 반환
      func dayOfWeek() -> String {
          let dateFormatter = DateFormatter()
          dateFormatter.locale = Locale(identifier: "ko_KR")
          dateFormatter.dateFormat = "EEEE"
          return dateFormatter.string(from: self)
      }
}

extension String {
    
    // ISO 8601 시간 문자열을 Date 객체로 변환하는 함수
    func isoStringToDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"  // 문자열의 형식 지정
        dateFormatter.timeZone = TimeZone(identifier: "UTC")  // UTC 시간대 설정
        return dateFormatter.date(from: dateString)
    }
    
    // ISO 8601 형식의 시간을 Date로 변환하고 한국 시간으로 변환하는 함수
    func convertISOToKoreanTime(isoString: String) -> String {
        let dateFormatter = DateFormatter()
          
          // 서버에서 받은 형식에 맞춘 포맷 설정 (ISO 형식이 아닌 일반 날짜 형식)
          dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
          dateFormatter.timeZone = TimeZone(identifier: "UTC")  // 입력은 UTC 기준

        // 1. ISO 8601 형식 문자열을 Date로 변환
        guard let date = dateFormatter.date(from: isoString) else {
            return "시간 변환 오류"
        }

        // 2. DateFormatter를 사용하여 한국 시간으로 변환된 시간 포맷팅
        dateFormatter.dateFormat = "a h시" // 원하는 시간 형식 (오전 11시)
        dateFormatter.locale = Locale(identifier: "ko_KR") // 한국어
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")! // 한국 시간대
        
        // 3. 변환된 한국 시간 반환
        return dateFormatter.string(from: date)
    }
}
