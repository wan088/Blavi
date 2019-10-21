//
//  Search_Result.swift
//  Blavi
//
//  Created by Yongwan on 12/09/2019.
//  Copyright © 2019 Yongwan. All rights reserved.
//

import Foundation
// MARK: - Search_Result
struct Search_Result: Codable {
    let status: String
    let meta: Meta
    let places: [Place]
    let errorMessage: String
}

// MARK: - Meta
struct Meta: Codable {
    let totalCount, count: Int
}

