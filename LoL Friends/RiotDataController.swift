//
//  RiotDataController.swift
//  LoL Friends
//
//  Created by Arielle Vaniderstine on 2017-01-02.
//  Copyright © 2017 Citron Digital. All rights reserved.
//

import Cocoa

class RiotDataController: NSObject {
    
    var regions = [
        Region(displayName: "North America", code: "na", platformId: "NA1"),
        Region(displayName: "Europe West", code: "euw", platformId: "EUW1"),
        Region(displayName: "Europe Nordic/East", code: "eune", platformId: "EUNE1"),
        Region(displayName: "Oceania", code: "oce", platformId: "OC1")
    ]

    let apiKey = Key.api_key
    
    static let shared = RiotDataController()
    
    func getSummonerInfo(summonerNames: [String], region: Region, completionHandler: @escaping ([String : AnyObject]?, NSError?) -> Void ) {
        
        let summonerNamesString = summonerNames.joined(separator: ",")
        
        let urlString = String("https://oce.api.pvp.net/api/lol/\(region.code)/v1.4/summoner/by-name/\(summonerNamesString)?api_key=\(apiKey)")
        
        let request = URLRequest(url: URL(string: urlString!)!)
        
        var json = [String : AnyObject]()
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in
            if(error != nil){
                completionHandler(nil, error as NSError?)
            } else {
                do {
                    json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    completionHandler(json, nil)
                }
                catch {
                    print("you done fucked up")
                }
            }
        })
        task.resume()
    }
    
    func isInGame(summoner: Summoner, completionHandler: @escaping (Bool, NSError?) -> Void ) {
        
        let urlString = String("https://oce.api.pvp.net/observer-mode/rest/consumer/getSpectatorGameInfo/\(summoner.region.platformId)/\(summoner.id)?api_key=\(apiKey)")
        
        let request = URLRequest(url: URL(string: urlString!)!)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in
            if(error != nil){
                completionHandler(false, error as NSError?)
            } else {
                do {
                    let httpResponse = response as! HTTPURLResponse
                    if httpResponse.statusCode == 200 {
                        completionHandler(true, nil)
                    }
                    else {
                        completionHandler(false, nil)
                    }
                }
                catch {
                    print("you done fucked up")
                }
            }
        })
        task.resume()
    }
    
    func getRegionByCode(code: String) -> Region? {
        for region in regions {
            if code == region.code {
                return region
            }
        }
        return nil
    }

}
