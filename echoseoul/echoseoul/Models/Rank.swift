//
//  Rank.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/19.
//

import Foundation

struct Rank {
    var nickName: String
    var steps: Int
    var distance: Double
    var calories: Double
    var clearCount: Int
    var region: String
    var uuid: String
    
    func getScore() -> Int {
        return Int(steps / 10) + Int(distance / 10) + Int(clearCount * 100) + Int(calories)
    }
}
