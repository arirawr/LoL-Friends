//
//  FriendViewController.swift
//  LoL-Friends
//
//  Created by Arielle Vaniderstine on 2017-01-02.
//  Copyright © 2017 Citron Digital. All rights reserved.
//

import Cocoa

class FriendViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var addFriendTextField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var regionSelectButton: NSPopUpButton!
    @IBOutlet weak var errorMessageTextField: NSTextField!
    
    var friends = [Summoner]()
    
    var region = RiotDataController.shared.getRegionByCode(code: "")
    
    var errorCode = 0
    
    var storedFriendsNames: [String] {
        get {
            if let stored = UserDefaults.standard.value(forKey: "friends") as? [String] {
                return stored
            }
            return [String]()
        }
    }
    
    var uniqueIds: [String] {
        get {
            if let stored = UserDefaults.standard.value(forKey: "uniqueIds") as? [String] {
                return stored
            }
            return [String]()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSummonerInfo()
        // Update summoner info and view every 60 seconds
        _ = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(timedUpdate), userInfo: nil, repeats: true)
    }
    
    func timedUpdate() {
        fetchSummonerInfo()
    }
    
    @IBAction func refreshPress(_ sender: Any) {
        fetchSummonerInfo()
    }
    
    @IBAction func addFriendPress(_ sender: Any) {
        let standardName = addFriendTextField.stringValue.lowercased().replacingOccurrences(of: " ", with: "")
        
        var idArray = uniqueIds
        
        setRegion()
        
        progressIndicator.startAnimation(self)
        resetUI()
        
        RiotDataController.shared.getSummonerId(summonerName: standardName, region: region!) { data, error in
            
            guard data > 0 else {
                self.displayMessage(message: "Summmoner not found.")
                return
            }
            
            let uniqueId = (self.region!.code) + ".\(data)"
            
            guard !idArray.contains(uniqueId) else {
                return
            }
            
            idArray.append(uniqueId)
            UserDefaults.standard.set(idArray, forKey: "uniqueIds")
            self.fetchSummonerInfo()
        }
        
        addFriendTextField.stringValue = ""
        
    }
    
    @IBAction func removeFriendPress(_ sender: Any) {
        let index = (sender as! NSButton).tag
        var idArray = uniqueIds
        let idToRemove = friends[index].getUniqueId()
        idArray = idArray.filter{$0 != idToRemove}
        
        UserDefaults.standard.set(idArray, forKey: "uniqueIds")
        
        fetchSummonerInfo()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.make(withIdentifier: "FriendCell", owner: self) as! FriendCellView
        cellView.textField?.stringValue = (self.friends[row].name)
        cellView.regionTextField?.stringValue = (self.friends[row].region.code.uppercased())
        if self.friends[row].isInGame {
            cellView.statusBox?.layer?.backgroundColor = NSColor.green.cgColor
        } else {
            cellView.statusBox?.layer?.backgroundColor = NSColor.red.cgColor
        }
        cellView.button.target = self
        cellView.button.action = #selector(removeFriendPress(_:))
        cellView.button.tag = row
        return cellView
    }
    
    func setRegion() {
        let selectedRegion = regionSelectButton.titleOfSelectedItem?.lowercased()
        region = RiotDataController.shared.getRegionByCode(code: selectedRegion!)
    }
    
    func displayMessage(message: String) {
        errorMessageTextField.stringValue = message
        view.addSubview(errorMessageTextField)
    }
    
    func clearMessages() {
        errorMessageTextField.stringValue = " "
        errorMessageTextField.removeFromSuperview()
    }
    
    func fetchSummonerInfo() {
        progressIndicator.startAnimation(self)
        
        //Reset UI
        friends.removeAll()
        resetUI()
        
        //Loop through stored summoner IDs
        for uniqueId in uniqueIds {
            let splitId = uniqueId.components(separatedBy: ".")
            guard let summonerRegion = RiotDataController.shared.getRegionByCode(code: splitId[0]) else {
                print("Unable to get region!")
                continue
            }
            guard splitId.count > 1, let summonerId = Int(splitId[1]) else {
                print("Unable to get summonerId from unique Id!")
                continue
            }
            
            //Retreive current summoner data and create a Summoner object
            RiotDataController.shared.getSummonerInfoById(summonerId: summonerId, region: summonerRegion) { data, error in
                guard error == nil else {
                    self.errorCode = (error?.code)!
                    DispatchQueue.main.async {
                        self.updateUI()
                    }
                    return
                }
                guard let dict = data else {
                    print("Malformed response!")
                    return
                }
                
                guard let summoner = Summoner(data: dict, region: summonerRegion) else {
                    print("Unable to create summoner! Missing values.")
                    return
                }
                
                //Find if current summoner is in game and update Summoner object
                RiotDataController.shared.isInGame(summoner: summoner) { data, error in
                    guard error == nil else {
                        self.errorCode = (error?.code)!
                        DispatchQueue.main.async {
                            self.updateUI()
                        }
                        return
                    }
                    summoner.updateIsInGame(data: data)
                    //Add summoner to friends
                    self.friends.append(summoner)
                    
                    DispatchQueue.main.async {
                        self.updateUI()
                    }
                }
                
            }
        }
    }
    
    func resetUI() {
        self.clearMessages()
        errorCode = 0
    }
    
    func updateUI() {
        tableView.reloadData()
        progressIndicator.stopAnimation(self)
        
        if(self.errorCode == 429) {
            self.displayMessage(message: "Rate limit reached. Please wait before refreshing.")
        } else if(self.errorCode == 404) {
            self.displayMessage(message: "Not found.")
        } else if(self.errorCode != 0) {
            self.displayMessage(message: "Error")
        }
    }
}
