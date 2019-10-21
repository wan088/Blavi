//
//  Place.swift
//  Blavi
//
//  Created by Yongwan on 20/10/2019.
//  Copyright © 2019 Yongwan. All rights reserved.
//

import Foundation
// MARK: - Place
struct Place: Codable {
    let name, roadAddress, jibunAddress, phoneNumber: String
    let x, y: String
    let distance: Double
    let sessionID: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case roadAddress = "road_address"
        case jibunAddress = "jibun_address"
        case phoneNumber = "phone_number"
        case x, y, distance
        case sessionID = "sessionId"
    }
}
