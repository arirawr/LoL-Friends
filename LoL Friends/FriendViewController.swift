//
//  FriendViewController.swift
//  LoL Friends
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
    
    var friends = [Summoner]()
    
    var region = RiotDataController.shared.getRegionByCode(code: "")
    
    var storedFriendsNames: [String] {
        get {
            if let stored = UserDefaults.standard.value(forKey: "friends") as? [String] {
                return stored
            }
            return [String]()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSummonerInfo()
    }
    
    @IBAction func refreshPress(_ sender: Any) {
        fetchSummonerInfo()
    }
    
    @IBAction func addFriendPress(_ sender: Any) {
        var friendsArray = storedFriendsNames
        let standardName = addFriendTextField.stringValue.lowercased().replacingOccurrences(of: " ", with: "")
        guard !friendsArray.contains(standardName) else {
            return
        }
        friendsArray.append(standardName)
        UserDefaults.standard.set(friendsArray, forKey: "friends")
        fetchSummonerInfo()
    }
    
    @IBAction func removeFriendPress(_ sender: Any) {
        let index = (sender as! NSButton).tag
        var friendsArray = storedFriendsNames
        let name = friends[index].getStandardName()
        friendsArray = friendsArray.filter{$0 != name}
        
        UserDefaults.standard.set(friendsArray, forKey: "friends")

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
    
    func fetchSummonerInfo() {
        progressIndicator.startAnimation(self)
        setRegion()
        if !storedFriendsNames.isEmpty {
            RiotDataController.shared.getSummonerInfo(summonerNames: storedFriendsNames, region: region!) { data, error in
                if data != nil {
                    self.friends.removeAll()
                    for dict in data! {
                        print(dict.value)
                        let summoner = Summoner(data: dict.value as! [String : AnyObject], region: self.region!)
                        RiotDataController.shared.isInGame(summoner: summoner) { data, error in
                            summoner.updateIsInGame(data: data)
                            print(summoner.isInGame)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.progressIndicator.stopAnimation(self)
                                
                            }
                        }
                        self.friends.append(summoner)
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.progressIndicator.stopAnimation(self)
                    }
                } else {
                    // handle error
                }
            }
        }
    }
    
    
}
