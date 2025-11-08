//
//  Statistics.swift
//  BetaBuddy
//
//  Created by Nikola Cao on 11/7/25.
//

import Foundation

public struct Statistics: Codable, Equatable {
    
    var numClimbs: Int = 0
    
    var vb: Int = 0
    var v0tov1: Int = 0
    var v1tov2: Int = 0
    var v2tov4: Int = 0
    var v4tov6: Int = 0
    var v6tov8: Int = 0
    var v8tov10: Int = 0
    var v10tov12: Int = 0
    var v12plus: Int = 0
    
    init() {
        
    }
    
    init(numClimbs: Int, vb: Int, v0tov1: Int, v1tov2: Int, v2tov4: Int, v4tov6: Int, v6tov8: Int, v8tov10: Int, v10tov12: Int, v12plus: Int) {
        self.numClimbs = numClimbs
        self.vb = vb
        self.v0tov1 = v0tov1
        self.v1tov2 = v1tov2
        self.v2tov4 = v2tov4
        self.v4tov6 = v4tov6
        self.v6tov8 = v6tov8
        self.v8tov10 = v8tov10
        self.v10tov12 = v10tov12
        self.v12plus = v12plus
    }
    
}

enum Grades: String, CaseIterable {
    
    case vb = "vb"
    case v0tov1 = "v0-v1"
    case v1tov2 = "v1-v2"
    case v2tov4 = "v2-v4"
    case v4tov6 = "v4-v6"
    case v6tov8 = "v6-v8"
    case v8tov10 = "v8-v10"
    case v10tov12 = "v10-v12"
    case v12plus = "v12+"
}
