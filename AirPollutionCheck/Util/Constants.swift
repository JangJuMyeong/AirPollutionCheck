//
//  Constants.swift
//  AirPollutionCheck
//
//  Created by 장주명 on 2021/06/03.
//

import Foundation

enum API {
    static let NAVER_CLIENT_ID = "kdv8sintbx"
    static let NAVER_CLIENT_SECRET = "h5OONzeB4lbHTW1le694OXkPXQXHKNxdGgwnihO0"
    static let NAVER_REVERSGEOCODE_URL = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?coords="
    static let NAVER_GEOCODE_URL = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query="
    static let ADDRESS = "37.636796,126.700795"
    static let 홍대입구역 = "서울시 마포구 동교동"
    
}

enum AirPollutionAPI {
    static let AIR_POLLUTION_URL = "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc"

}
