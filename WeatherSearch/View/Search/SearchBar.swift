//
//  SearchBarView.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/7/24.
//


import UIKit
import SnapKit

class SearchBar: UIView {
    
    let searchBar = UISearchBar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 검색바를 추가하고 기본 설정
        addSubview(searchBar)
        searchBar.placeholder = "Search"
        searchBar.backgroundImage = UIImage() // 배경 없애기
        searchBar.barTintColor = .clear
        //searchBar.searchTextField.backgroundColor = .white
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .clear // 검색 필드 배경 투명하게 설정
            textField.layer.backgroundColor = UIColor.txtFieldColor?.cgColor
            textField.layer.cornerRadius = 20
            textField.layer.masksToBounds = true
        }
        
        searchBar.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
}
