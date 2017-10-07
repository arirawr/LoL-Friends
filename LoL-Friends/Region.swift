//
//  Region.swift
//  LoL-Friends
//
//  Created by Arielle Vaniderstine on 2017-01-03.
//  Copyright © 2017 Citron Digital. All rights reserved.
//

import Cocoa

class Region: NSObject {
    
    var displayName: String
    var code: String
    var platformId: String
    
    init(displayName: String, code: String, platformId: String) {
        self.displayName = displayName
        self.code = code
        self.platformId = platformId
        super.init()
    }

}
