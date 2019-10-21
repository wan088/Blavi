//
//  ViewModelBindableType.swift
//  Blavi
//
//  Created by Yongwan on 21/10/2019.
//  Copyright © 2019 Yongwan. All rights reserved.
//

import UIKit

protocol ViewModelBindableType{
    associatedtype ViewModelType
    
    var ViewModel: ViewModelType! { get set }
    func bindViewModel()
}
extension ViewModelBindableType where Self: UIViewController {
    mutating func bind(viewModel: Self.ViewModelType){
        self.ViewModel = ViewModel
        loadViewIfNeeded()
        bindViewModel()
    }
}
