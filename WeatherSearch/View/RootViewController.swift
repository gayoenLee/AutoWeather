//
//  RootViewController.swift
//  YourWeather
//
//  Created by 이은호 on 10/4/24.
//

import UIKit

class RootViewController: UINavigationController {
    
    
    private lazy var weatherViewController: UIViewController = {
        let service = WeatherAPIService()
        let viewModel = WeatherViewModel(weatherService: service)
        let mainViewController = WeatherViewController(viewModel: viewModel)
        return mainViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewControllers([weatherViewController], animated: false)
    }
    
    
}
