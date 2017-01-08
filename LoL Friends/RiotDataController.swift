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
        Region(displayName: "Europe Nordic/East", code: "eune", platformId: "EUN1"),
        Region(displayName: "Brazil", code: "br", platformId: "BR1"),
        Region(displayName: "Oceania", code: "oce", platformId: "OC1"),
        Region(displayName: "Japan", code: "jp", platformId: "JP1"),
        Region(displayName: "Korea", code: "kr", platformId: "KR1"),
        Region(displayName: "Latin America North", code: "lan", platformId: "LA1"),
        Region(displayName: "Latin America South", code: "las", platformId: "LA2"),
        Region(displayName: "Turkey", code: "tr", platformId: "TR1"),
        Region(displayName: "Russia", code: "ru", platformId: "RU"),
        Region(displayName: "Public Beta Environment", code: "pbe", platformId: "PBE")
    ]

    let apiKey = Key.api_key
    
    static let shared = RiotDataController()
    
    func getSummonerId(summonerName: String, region: Region, completionHandler: @escaping ( Int, NSError?) -> Void ) {
        let urlString = String("https://\(region.code).api.pvp.net/api/lol/\(region.code)/v1.4/summoner/by-name/\(summonerName)?api_key=\(apiKey)").addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        print(urlString)
        
        let request = URLRequest(url: URL(string: urlString!)!)
        
        var json = [String : AnyObject]()
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in
            if(error != nil){
                completionHandler(0, error as NSError?)
            } else if((response as! HTTPURLResponse).statusCode == 429) {
                completionHandler(0, NSError(domain: "digital.citron.LoL-Friends", code: 429, userInfo: nil))
            } else if((response as! HTTPURLResponse).statusCode != 200) {
                completionHandler(0, NSError(domain: "digital.citron.LoL-Friends", code: 404, userInfo: nil))
            } else {
                do {
                    json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let summonerId = json.first?.value["id"]
                    print(json)
                    print(summonerId)
                    completionHandler(summonerId as! Int, nil)
                }
                catch {
                    print("you done fucked up")
                }
            }
        })
        task.resume()
    }
    
    func getSummonerInfoById(summonerId: Int, region: Region, completionHandler: @escaping ([String : AnyObject]?, NSError?) -> Void ) {
        
        let urlString = String("https://\(region.code).api.pvp.net/api/lol/\(region.code)/v1.4/summoner/\(summonerId)?api_key=\(apiKey)")
        
        print(urlString)
        
        let request = URLRequest(url: URL(string: urlString!)!)
        
        var json = [String : AnyObject]()
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in
            if(error != nil){
                completionHandler(nil, error as NSError?)
            } else if((response as! HTTPURLResponse).statusCode == 429) {
                completionHandler(nil, NSError(domain: "digital.citron.LoL-Friends", code: 429, userInfo: nil))
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
    
    func getSummonerInfo(summonerNames: [String], region: Region, completionHandler: @escaping ([String : AnyObject]?, NSError?) -> Void ) {
        
        let summonerNamesString = summonerNames.joined(separator: ",")
        
        let urlString = String("https://\(region.code).api.pvp.net/api/lol/\(region.code)/v1.4/summoner/by-name/\(summonerNamesString)?api_key=\(apiKey)")
        
        print(urlString)
        
        let request = URLRequest(url: URL(string: urlString!)!)
        
        var json = [String : AnyObject]()
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in
            if(error != nil){
                completionHandler(nil, error as NSError?)
            } else if((response as! HTTPURLResponse).statusCode == 429) {
                completionHandler(nil, NSError(domain: "digital.citron.LoL-Friends", code: 429, userInfo: nil))
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
        
        let urlString = String("https://\(summoner.region.code).api.pvp.net/observer-mode/rest/consumer/getSpectatorGameInfo/\(summoner.region.platformId)/\(summoner.id)?api_key=\(apiKey)")
        
        print(urlString)
        
        let request = URLRequest(url: URL(string: urlString!)!)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in
            if(error != nil){
                completionHandler(false, error as NSError?)
            } else if((response as! HTTPURLResponse).statusCode == 429) {
                completionHandler(false, NSError(domain: "digital.citron.LoL-Friends", code: 429, userInfo: nil))
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
