//
//  APIClient.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/6/24.
//

import Foundation
import RxSwift
import Alamofire



public struct APIClient<Request: BaseAPIURLConvertable, Response: Decodable> {
    let request: Request
    
    init(request: Request) {
        self.request = request
    }
    
    public func requestData() -> Single<Response> {
        return Single<Response>.create { single in
            let dataRequest = self.request.asDataRequset()
                .validate()
                .responseDecodable(of: Response.self) { response in
                    switch response.result {
                    case .success(let data):
                        
                        single(.success(data))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            return Disposables.create {
                dataRequest.cancel()
            }
            
        }
    }
}
