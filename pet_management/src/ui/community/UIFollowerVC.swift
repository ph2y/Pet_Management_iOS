//
//  UIFollowerVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/18.
//

import UIKit;

class UIFollowerVC: UIViewController {
    @IBOutlet weak var userTableView: UITableView!;
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!;
    @IBOutlet weak var nicknameSearchBar: UISearchBar!;
    
    var followerList: [Account] = [];
    var followingList: [Account] = [];
    var searchResultList: [Account] = [];
    
    override func viewDidLoad() {
        
    }
}

// Extension - UITableViewDelegate
extension UIFollowerVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (self.categorySegmentedControl.selectedSegmentIndex) {
        case 0:
            return self.followerList.isEmpty ? 1 : self.followerList.count;
        case 1:
            return self.followingList.isEmpty ? 1 : self.followingList.count;
        case 2:
            return self.searchResultList.isEmpty ? 1 : self.searchResultList.count;
        default:
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (self.categorySegmentedControl.selectedSegmentIndex) {
        case 0:
            if (self.followerList.isEmpty) {
                return tableView.dequeueReusableCell(withIdentifier: "followEmpty")!;
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "followCell") as! UIFollowerCellVC;
                cell.followAccount = self.followerList[indexPath.row];
                cell.senderVC = self;
                cell.initCell();
                return cell;
            }
        case 1:
            if (self.followingList.isEmpty) {
                return tableView.dequeueReusableCell(withIdentifier: "followEmpty")!;
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "followCell") as! UIFollowerCellVC;
                cell.followAccount = self.followingList[indexPath.row];
                cell.senderVC = self;
                cell.initCell();
                return cell;
            }
        case 2:
            if (self.searchResultList.isEmpty) {
                return tableView.dequeueReusableCell(withIdentifier: "followSearchEmpty")!;
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "followCell") as! UIFollowerCellVC;
                cell.followAccount = self.searchResultList[indexPath.row];
                cell.senderVC = self;
                cell.initCell();
                return cell;
            }
        default:
            return tableView.dequeueReusableCell(withIdentifier: "followEmpty")!;
        }
    }
    
    
}

// Extension - UISearchBarDelegate
extension UIFollowerVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        AccountUtil.reqHttpFetchAccountByNickname(nickname: self.nicknameSearchBar.text!, sender: self) {
            (res) in
            
        }
    }
}
