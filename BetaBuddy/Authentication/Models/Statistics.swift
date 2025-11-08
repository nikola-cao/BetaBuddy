//
//  Statistics.swift
//  BetaBuddy
//
//  Created by Nikola Cao on 11/7/25.
//

import Foundation

public struct Statistics {
    
    var numClimbs: Int
    
    var vb: Int
    var v0tov1: Int
    var v1tov2: Int
    var v2tov4: Int
    var v4tov6: Int
    var v6tov8: Int
    var v8tov10: Int
    var v10tov12: Int
    var v12plus: Int
    
    init() {
        self.numClimbs = 0
        self.vb = 0
        self.v0tov1 = 0
        self.v1tov2 = 0
        self.v2tov4 = 0
        self.v4tov6 = 0
        self.v6tov8 = 0
        self.v8tov10 = 0
        self.v10tov12 = 0
        self.v12plus = 0
    }
    
}

enum Grades: CaseIterable {
    
    case vb
    case v0tov1
    case v1tov2
    case v2tov4
    case v4tov6
    case v6tov8
    case v8tov10
    case v10tov12
    case v12plus
}
