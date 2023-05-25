//
//  PlaceData.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/18.
//

struct SpaceInfo: Codable {
    let culturalSpaceInfo: CulturalSpaceInfo
}

struct CulturalSpaceInfo: Codable {
    let listTotalCount: Int
    let result: Result
    let row: [Place]
    
    enum CodingKeys: String, CodingKey {
        case listTotalCount = "list_total_count"
        case result = "RESULT"
        case row = "row"
    }
}

// Result structure
struct Result: Codable {
    let code: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case code = "CODE"
        case message = "MESSAGE"
    }
}

struct Place: Codable {
    var isCompleted: Bool = false
    var distance: Double = 0.0
    let num: String
    let subjcode: String
    let facName: String
    let addr: String
    let xCoord: String
    let yCoord: String
    let phne: String
    let fax: String
    let homepage: String
    let openhour: String
    let entrFee: String
    let closeday: String
    let openDay: String
    let seatCnt: String
    let mainImg: String
    let etcDesc: String
    let facDesc: String
    let entrFree: String
    let subway: String
    let busstop: String
    let yellow: String
    let green: String
    let blue: String
    let red: String
    let airport: String
    
    enum CodingKeys: String, CodingKey {
        case num = "NUM"
        case subjcode = "SUBJCODE"
        case facName = "FAC_NAME"
        case addr = "ADDR"
        case xCoord = "X_COORD"
        case yCoord = "Y_COORD"
        case phne = "PHNE"
        case fax = "FAX"
        case homepage = "HOMEPAGE"
        case openhour = "OPENHOUR"
        case entrFee = "ENTR_FEE"
        case closeday = "CLOSEDAY"
        case openDay = "OPEN_DAY"
        case seatCnt = "SEAT_CNT"
        case mainImg = "MAIN_IMG"
        case etcDesc = "ETC_DESC"
        case facDesc = "FAC_DESC"
        case entrFree = "ENTRFREE"
        case subway = "SUBWAY"
        case busstop = "BUSSTOP"
        case yellow = "YELLOW"
        case green = "GREEN"
        case blue = "BLUE"
        case red = "RED"
        case airport = "AIRPORT"
    }
}
