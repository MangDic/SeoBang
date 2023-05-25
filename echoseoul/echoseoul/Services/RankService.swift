//
//  RankService.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/23.
//

import Foundation
import FirebaseDatabase
import RxCocoa
import RxSwift

class RankService {
    static let shared = RankService()
    
    let db = Database.database().reference()
    
    var disposeBag = DisposeBag()
    let dataRelay = BehaviorRelay<[Rank]>(value: [])
    let selectRelay = BehaviorRelay<RankType>(value: .region)
    var regionArr = [Rank]()
    var individualArr = [Rank]()
    let regions = ["강남구", "강동구", "강북구", "강서구", "관악구", "광진구", "구로구", "금천구", "노원구", "도봉구", "동대문구", "동작구", "마포구", "서대문구", "서초구", "성동구", "성북구", "송파구", "양천구", "영등포구", "용산구", "은평구", "종로구", "중구", "중랑구"]
    
    private init() {
        loadData()
        addObserver()
        bind()
    }
    
    func findRegionRank() -> Int {
        for (i, rank) in regionArr.enumerated() {
            if rank.region == UserInfoService.shared.region {
                return i + 1
            }
        }
        return 0
    }
    
    func findIndividualRank() -> Int {
        for (i, rank) in individualArr.enumerated() {
            if rank.uuid == UserInfoService.shared.uuid {
                return i + 1
            }
        }
        return 0
    }
    
    private func addObserver() {
        let userRef = db.child("Users")
        
        userRef.observe(.value, with: { [weak self] (snapshot) in
            guard let `self` = self else { return }
            if let usersDict = snapshot.value as? [String: Any] {
                var users = [Rank]()
                for (_, value) in usersDict {
                    if let userDict = value as? [String: Any],
                       let nickName = userDict["nickName"] as? String,
                       let region = userDict["region"] as? String,
                       let clearCount = userDict["clearCount"] as? Int,
                       let calories = userDict["calories"] as? Double,
                       let distance = userDict["distance"] as? Double,
                       let steps = userDict["steps"] as? Int,
                       let uuid = userDict["uuid"] as? String {
                        let user = Rank(nickName: nickName, steps: steps, distance: distance, calories: calories, clearCount: clearCount, region: region, uuid: uuid)
                        users.append(user)
                    }
                }
                self.setupRegionData(rankArr: users)
                self.setupIndividualData(arr: users)
            }
        })
    }

    private func loadData() {
        db.child("users").observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            guard let `self` = self else { return }
            
            if let usersDict = snapshot.value as? [String: Any] {
                var users = [Rank]()
                for (key, value) in usersDict {
                    if let userDict = value as? [String: Any],
                       let nickName = userDict["nickName"] as? String,
                       let region = userDict["region"] as? String,
                       let clearCount = userDict["clearCount"] as? Int,
                       let calories = userDict["calories"] as? Double,
                       let distance = userDict["distance"] as? Double,
                       let steps = userDict["steps"] as? Int {
                        let user = Rank(nickName: nickName,
                                        steps: steps,
                                        distance: distance,
                                        calories: calories,
                                        clearCount: clearCount,
                                        region: region,
                                        uuid: key)
                        users.append(user)
                    }
                }
                self.setupRegionData(rankArr: users)
                self.setupIndividualData(arr: users)
                
                self.dataRelay.accept(self.regionArr)
            }
        })
    }
    
    func uploadData(user: Rank, completion: @escaping (Error?) -> Void) {
        let key = user.uuid
        let userData: [String: Any] = [
            "nickName": user.nickName,
            "region": user.region,
            "clearCount": user.clearCount,
            "calories": user.calories,
            "distance": user.distance,
            "steps": user.steps
        ]
        db.child("users").child(key).setValue(userData) { [weak self] (error, _) in
            guard let `self` = self else { return }
            if error == nil {
                self.loadData()
            }
            completion(error)
        }
    }
    
    private func bind() {
        selectRelay.subscribe(onNext: { [weak self] type in
            guard let `self` = self else { return }
            switch type {
            case .region:
                self.dataRelay.accept(self.regionArr)
            case .individual:
                self.dataRelay.accept(self.individualArr)
            }
        }).disposed(by: disposeBag)
    }
    
    private func setupRegionData(rankArr: [Rank]) {
        var regionDic = [String: Rank]()
        
        regions.forEach {
            regionDic[$0] = Rank(nickName: $0, steps: 0, distance: 0, calories: 0, clearCount: 0, region: $0, uuid: $0)
        }
        
        for rank in rankArr {
            if regionDic[rank.region] != nil {
                regionDic[rank.region]!.steps += rank.steps
                regionDic[rank.region]!.distance += rank.distance
                regionDic[rank.region]!.calories += rank.calories
                regionDic[rank.region]!.clearCount += rank.clearCount
            }
        }
        let arr = Array(regionDic.values)
        
        regionArr = arr.sorted(by: { $0.getScore() > $1.getScore() })
    }
    
    private func setupIndividualData(arr: [Rank]) {
        individualArr = arr.sorted(by: { $0.getScore() > $1.getScore() })
    }
    
    func updateMyData(completion: @escaping (Error?) -> Void ) {
        let nickName = UserInfoService.shared.userNickName
        let region = UserInfoService.shared.region
        let steps = HealthService.shared.stepsRelay.value
        let distance = HealthService.shared.distanceRelay.value
        let calories = HealthService.shared.caloriesRelay.value
        let clearCount = UserInfoService.shared.clearCount
        let uuid = UserInfoService.shared.uuid
        
        let userData = Rank(nickName: nickName,
                            steps: steps,
                            distance: distance,
                            calories: calories,
                            clearCount: clearCount,
                            region: region,
                            uuid: uuid)
        
        RankService.shared.uploadData(user: userData, completion: { error in
            if let error = error {
                completion(error)
            }
            else {
                RankService.shared.loadData()
                completion(nil)
            }
        })
    }
}
