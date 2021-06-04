//
//  LocationInfo.swift
//  AirPollutionCheck
//
//  Created by 장주명 on 2021/06/04.
//

import Foundation

class LocationInfo {
    
    static let shared = LocationInfo()
    
    var nowLocationName: String?
    var longitude: Double?
    var latitude: Double?
    var pmValue : String?
    var pmGradeValue: String?
    var dataTime: String?
    var stationName: String?
 

    private init() { }
}
