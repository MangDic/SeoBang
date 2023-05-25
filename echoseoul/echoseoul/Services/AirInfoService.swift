//
//  AirInfoService.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/17.
//

import Foundation
import RxCocoa

class AirInfoService {
    static let shared = AirInfoService()
    
    var currentCityData: Region?
    var airInfoRelay = BehaviorRelay<[Weather]>(value: [])
    var regionDataArr = [Region]()
    var regionDataRelay = BehaviorRelay<[Region]>(value: [])
    var cityRelay = BehaviorRelay<[String]>(value: [])
    
    private init() {
        loadData()
    }
    
    private func loadData() {
        // API URL 생성
        let userKey = "695948497572656d36344655456b62"
        let urlString = "http://openAPI.seoul.go.kr:8088/\(userKey)/json/RealtimeCityAir/1/30/"
        let url = URL(string: urlString)!
        
        // URLSession을 사용한 네트워크 요청
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            }
            else if let data = data {
                let decoder = JSONDecoder()
                do {
                    let cityAirData = try decoder.decode(RegionAirInfo.self, from: data)
                    self.regionDataArr = cityAirData.RealtimeCityAir.row.sorted(by: { $0.MSRSTE_NM < $1.MSRSTE_NM })
                    self.regionDataRelay.accept(self.regionDataArr)
                    self.cityRelay.accept(self.regionDataArr.map { $0.MSRSTE_NM })
                    if let first = self.regionDataArr.first {
                        let _ = self.findRegionData(target: first.MSRSTE_NM)
                    }
                } catch {
                    print("Error: \(error)")
                }
            }
        }
        task.resume()
    }
    
    func findRegionData(target: String) -> Region? {
        var data: Region? = nil
        regionDataArr.forEach {
            if $0.MSRSTE_NM == target {
                currentCityData = $0
                data = $0
                getAirInfo()
            }
        }
        
        return data
    }
    
    func getAirInfo() {
        var arr = [Weather]()
        
        if let currentCityData = currentCityData {
            let co = Weather(name: "일산화탄소", value: currentCityData.CO)
            let o3 = Weather(name: "오존", value: currentCityData.O3)
            let PM10 = Weather(name: "미세먼지", value: currentCityData.PM10)
            let PM25 = Weather(name: "초미세먼지", value: currentCityData.PM25)
            
            arr.append(PM10)
            arr.append(PM25)
            arr.append(co)
            arr.append(o3)
        }
        
        airInfoRelay.accept(arr)
    }
}
