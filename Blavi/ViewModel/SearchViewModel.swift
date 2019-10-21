//
//  SearchViewModel.swift
//  Blavi
//
//  Created by Yongwan on 21/10/2019.
//  Copyright © 2019 Yongwan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
class SearchViewModel{
    
    var SearchBarRelay = PublishRelay<String>()
    var SearchTextObservable: Observable<String>!
    init() {
        setup()
    }
    func setup(){
        SearchTextObservable = SearchBarRelay
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
        .distinctUntilChanged()
            .filter{!$0.isEmpty}
    }
}
