//
//  Summoner.swift
//  LoL Friends
//
//  Created by Arielle Vaniderstine on 2017-01-02.
//  Copyright © 2017 Citron Digital. All rights reserved.
//

import Cocoa

class Summoner: NSObject {
    
    var name = String()
    var id: Int
    var region: Region
    var isInGame = Bool()
    
    init(data: [String : AnyObject], region: Region) {
        name = data["name"] as! String
        id = data["id"] as! Int
        self.region = region
        super.init()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let otherSummoner = object as? Summoner else {
            return false
        }
        return id == otherSummoner.id
    }
    
    func getStandardName() -> String {
        return name.lowercased().replacingOccurrences(of: " ", with: "")
    }
    
    func getUniqueId() -> String {
        return region.code + ".\(id)"
    }
    
    func updateIsInGame(data: Bool) {
        isInGame = data
    }
}
