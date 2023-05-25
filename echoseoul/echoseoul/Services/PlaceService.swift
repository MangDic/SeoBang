//
//  PlaceService.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/18.
//

import Foundation
import RxCocoa
import RxSwift
import CoreLocation

class PlaceService {
    static let shared = PlaceService()
    
    var disposeBag = DisposeBag()
    /// x, y
    let updateCurrentRelay = PublishRelay<(Double, Double)>()
    let placeRelay = BehaviorRelay<[Place]>(value: [])
    /// 특정 장소 도착 이벤트
    let completedRelay = PublishRelay<String>()
    /// 현재위치에서 가까운 위치 중 이 값만큼 보여줌
    let maxCount = 30
    
    private init() {
        loadData()
        bind()
    }
    
    func loadData() {
        let urlString = "http://openAPI.seoul.go.kr:8088/\(NetworkService.seoul_api_key)/json/culturalSpaceInfo/1/1000/"
        let url = URL(string: urlString)!
        
        // URLSession을 사용한 네트워크 요청
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let `self` = self else { return }
            
            if let error = error {
                print("Error: \(error)")
            }
            else if let data = data {
                // JSONDecoder를 사용한 파싱
                let decoder = JSONDecoder()
                do {
                    let spaceInfo = try decoder.decode(SpaceInfo.self, from: data)
                    let arr = Array(spaceInfo.culturalSpaceInfo.row.sorted(by: { $0.distance < $1.distance })[0...self.maxCount])
                    self.placeRelay.accept(arr)
                    
                } catch {
                    print("Error: \(error)")
                }
            }
        }
        task.resume()
    }
    
    private func bind() {
        Observable.combineLatest(updateCurrentRelay, AirInfoService.shared.regionDataRelay)
            .subscribe(onNext: { [weak self] dot, _ in
                guard let `self` = self else { return }
                self.updateDistance(lat: dot.0, lng: dot.1)
            }).disposed(by: disposeBag)
    }
    
    private func updateDistance(lat: Double, lng: Double) {
        var places = self.placeRelay.value
        var completedPlace = ""
        
        for (index, place) in places.enumerated() {
            let placeLat = Double(place.xCoord) ?? 0.0
            let placeLng = Double(place.yCoord) ?? 0.0
            let distance = getDistance(lat1: lat, lon1: lng, lat2: placeLat, lon2: placeLng)
            
            places[index].distance = distance
            if distance < 20, !place.isCompleted {
                completedPlace = place.facName
            }
        }
        
        if completedPlace != "" {
            completedRelay.accept(completedPlace)
        }
        
        placeRelay.accept(places.sorted(by: { $0.distance < $1.distance}))
    }
    
    private func getDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let coordinate1 = CLLocation(latitude: lat1, longitude: lon1)
        let coordinate2 = CLLocation(latitude: lat2, longitude: lon2)
        
        return coordinate1.distance(from: coordinate2) / 10.0
    }
}
