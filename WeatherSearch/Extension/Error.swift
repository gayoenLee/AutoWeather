//
//  Untitled.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/11/24.
//

import Foundation

enum CityListError: Error {
    case fileNotFound
    case decodingError
    case dataLoadingError
    case deallocated
}

extension CityListError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "파일을 찾을 수 없습니다."
        case .decodingError:
            return "JSON 데이터를 디코딩하는 중 오류가 발생했습니다."
        case .dataLoadingError, .deallocated:
            return "파일에서 데이터를 로드하는 중 오류가 발생했습니다."
        }
    }
}
