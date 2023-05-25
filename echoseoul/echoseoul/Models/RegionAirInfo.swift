//
//  RegionAirInfo.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/17.
//

import Foundation

struct RegionAirInfo: Decodable {
    let RealtimeCityAir: RealtimeCityAirInfo

    struct RealtimeCityAirInfo: Decodable {
        let list_total_count: Int
        let RESULT: Result
        let row: [Region]
    }

    struct Result: Decodable {
        let CODE: String
        let MESSAGE: String
    }
}

struct Region: Decodable {
    let MSRDT: String
    let MSRRGN_NM: String
    let MSRSTE_NM: String
    let PM10: Double
    let PM25: Double
    let O3: Double
    let NO2: Double
    let CO: Double
    let SO2: Double
    let IDEX_NM: String
    let IDEX_MVL: Double
    let ARPLT_MAIN: String
}
