//
//  MapData.swift
//  apple locations
//
//  Created by Kyle Hilla on 12/30/22.
//

import Foundation

struct LocationData: Codable {
    let location: String
    let address: String
    let city: String
    let state: String
    let zipCode: Int
    let phone: String
    let latitude: Double
    let longitude: Double
    let mapURL: String
    let storeURL: String
    let imageURL: String
    let details: String
    
    private enum CodingKeys: String, CodingKey {
        case location = "store_location"
        case address = "address"
        case city = "city"
        case state = "state"
        case zipCode = "zip_code"
        case phone = "phone"
        case latitude = "latitude"
        case longitude = "longitude"
        case mapURL = "map_url"
        case storeURL = "store_url"
        case imageURL = "image_url"
        case details = "details"
    }
}
