// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let featureCollection = try? newJSONDecoder().decode(FeatureCollection.self, from: jsonData)

import Foundation

// MARK: - FeatureCollection
class FeatureCollection: Codable {
    let type: String
    let features: [Feature]

    init(type: String, features: [Feature]) {
        self.type = type
        self.features = features
    }
}

// MARK: - Feature
class Feature: Codable {
    let type: String
    let geometry: Geometry
    let properties: Properties

    init(type: String, geometry: Geometry, properties: Properties) {
        self.type = type
        self.geometry = geometry
        self.properties = properties
    }
}

// MARK: - Geometry
class Geometry: Codable {
    let type: String
    let coordinates: [Coordinate]

    init(type: String, coordinates: [Coordinate]) {
        self.type = type
        self.coordinates = coordinates
    }
}

enum Coordinate: Codable {
    case double(Double)
    case doubleArray([Double])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([Double].self) {
            self = .doubleArray(x)
            return
            
        }
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        throw DecodingError.typeMismatch(Coordinate.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Coordinate"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .double(let x):
            try container.encode(x)
        case .doubleArray(let x):
            try container.encode(x)
        }
    }
}

// MARK: - Properties
class Properties: Codable {
    let index: Int
    let pointIndex: Int?
    let name: String
    let guidePointName: String?
    let propertiesDescription: String
    let direction, intersectionName, nearPoiName, nearPoiX: String?
    let nearPoiY, crossName: String?
    let turnType: Int?
    let pointType: String?
    let lineIndex: Int?
    let roadName: String?
    let distance, time, roadType, categoryRoadType: Int?
    let facilityType: Int?
    let facilityName: String?

    enum CodingKeys: String, CodingKey {
        case index, pointIndex, name, guidePointName
        case propertiesDescription = "description"
        case direction, intersectionName, nearPoiName, nearPoiX, nearPoiY, crossName, turnType, pointType, lineIndex, roadName, distance, time, roadType, categoryRoadType, facilityType, facilityName
    }

    init(index: Int, pointIndex: Int?, name: String, guidePointName: String?, propertiesDescription: String, direction: String?, intersectionName: String?, nearPoiName: String?, nearPoiX: String?, nearPoiY: String?, crossName: String?, turnType: Int?, pointType: String?, lineIndex: Int?, roadName: String?, distance: Int?, time: Int?, roadType: Int?, categoryRoadType: Int?, facilityType: Int?, facilityName: String?) {
        self.index = index
        self.pointIndex = pointIndex
        self.name = name
        self.guidePointName = guidePointName
        self.propertiesDescription = propertiesDescription
        self.direction = direction
        self.intersectionName = intersectionName
        self.nearPoiName = nearPoiName
        self.nearPoiX = nearPoiX
        self.nearPoiY = nearPoiY
        self.crossName = crossName
        self.turnType = turnType
        self.pointType = pointType
        self.lineIndex = lineIndex
        self.roadName = roadName
        self.distance = distance
        self.time = time
        self.roadType = roadType
        self.categoryRoadType = categoryRoadType
        self.facilityType = facilityType
        self.facilityName = facilityName
    }
}
