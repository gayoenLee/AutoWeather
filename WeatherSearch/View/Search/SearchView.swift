//
//  SearchView.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/7/24.
//

import UIKit
import SnapKit

final class SearchView: UIView {
    // 검색바와 테이블뷰를 포함하는 뷰
        let searchBar = SearchBar()
       let tableView = UITableView()
       
       override init(frame: CGRect) {
           super.init(frame: frame)
           setupView()
           setupConstraints()
       }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
       
       private func setupView() {
           addSubview(searchBar)
           addSubview(tableView)
           
           tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cityCell")
     
       }
       
       private func setupConstraints() {
           searchBar.snp.makeConstraints { make in
               make.top.equalTo(safeAreaLayoutGuide).offset(16)
               make.leading.trailing.equalToSuperview()
           }
           
           tableView.snp.makeConstraints { make in
               make.top.equalTo(searchBar.snp.bottom).offset(16)
               make.leading.trailing.bottom.equalToSuperview()
           }
       }
   }
