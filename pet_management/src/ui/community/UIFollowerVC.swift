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
    
    var accountDetail: [String: Any]?;
    var followerList: [Account] = [];
    var followingList: [Account] = [];
    var searchResultList: [Account] = [];
    
    override func viewDidLoad() {
        // Setup user details
        self.accountDetail = try! JSONSerialization.jsonObject(with: UserDefaults.standard.object(forKey: "loginAccountDetail") as! Data, options: []) as! [String: Any];
        
        // Setup UI delegates
        self.userTableView.delegate = self;
        self.userTableView.dataSource = self;
        self.nicknameSearchBar.delegate = self;
        
        // Display follower/following
        self.loadFollowerList();
        self.loadFollowingList();
    }
    
    func loadFollowerList() {
        AccountUtil.reqHttpFetchFollower(accountId: self.accountDetail!["id"] as! Int, sender: self) {
            (res) in
            self.followerList = res.value!.followerList;
            self.userTableView.reloadData();
        }
    }
    
    func loadFollowingList() {
        AccountUtil.reqHttpFetchFollowing(accountId: self.accountDetail!["id"] as! Int, sender: self) {
            (res) in
            self.followingList = res.value!.followingList;
            self.userTableView.reloadData();
        }
    }
    
    
    @IBAction func categorySegmentCtrlOnClick(_ sender: UISegmentedControl) {
        switch (self.categorySegmentedControl.selectedSegmentIndex) {
        case 0:
            self.loadFollowerList();
        case 1:
            self.loadFollowingList();
        case 2:
            self.userTableView.reloadData();
        default:
            self.userTableView.reloadData();
        }
    }
}

// Extension - UITableViewDelegate
extension UIFollowerVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (self.categorySegmentedControl.selectedSegmentIndex) {
        case 0:
            return self.followingList.isEmpty ? 1 : self.followingList.count;
        case 1:
            return self.followerList.isEmpty ? 1 : self.followerList.count;
        case 2:
            return self.searchResultList.isEmpty ? 1 : self.searchResultList.count;
        default:
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (self.categorySegmentedControl.selectedSegmentIndex) {
        case 0:
            if (self.followingList.isEmpty) {
                return tableView.dequeueReusableCell(withIdentifier: "followEmpty")!;
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "followCell") as! UIFollowerCellVC;
                cell.followAccount = self.followingList[indexPath.row];
                cell.senderVC = self;
                cell.initCell();
                return cell;
            }
        case 1:
            if (self.followerList.isEmpty) {
                return tableView.dequeueReusableCell(withIdentifier: "followEmpty")!;
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "followCell") as! UIFollowerCellVC;
                cell.followAccount = self.followerList[indexPath.row];
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cell = self.userTableView.cellForRow(at: indexPath) as? UIFollowerCellVC;
        
        guard(cell != nil) else {
            return UISwipeActionsConfiguration(actions:[]);
        }
        
        if (self.followerList.contains(where: {
            (account) in
            return account.id == cell!.followAccount!.id;
        })) {
            // If the user is already follows current account
            let unfollow = UIContextualAction(style: .destructive, title: "언팔로우") {
                (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
                AccountUtil.reqHttpDeleteFollow(accountId: cell!.followAccount!.id, sender: self) {
                    (res) in
                    self.loadFollowerList();
                }
            }
            unfollow.backgroundColor = .systemRed;
            return UISwipeActionsConfiguration(actions:[unfollow]);
        } else {
            // If the user doesn't following current account
            let follow = UIContextualAction(style: .destructive, title: "팔로우") {
                (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
                AccountUtil.reqHttpCreateFollow(accountId: cell!.followAccount!.id, sender: self) {
                    (res) in
                    self.loadFollowerList();
                }
            }
            follow.backgroundColor = .systemBrown;
            return UISwipeActionsConfiguration(actions:[follow]);
        }
    }
}

// Extension - UISearchBarDelegate
extension UIFollowerVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchResultList = [];
        self.categorySegmentedControl.selectedSegmentIndex = 2;
        guard(self.nicknameSearchBar.text != nil && !self.nicknameSearchBar.text!.isEmpty) else {
            return;
        }
        AccountUtil.reqHttpFetchAccountByNickname(nickname: self.nicknameSearchBar.text!, sender: self) {
            (res) in
            if (res.value!._metadata.status) {
                self.searchResultList.append(AccountUtil.getAccountFromFetchedDto(dto: res.value!));
            }
            self.userTableView.reloadData();
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchResultList = [];
        self.categorySegmentedControl.selectedSegmentIndex = 2;
        self.userTableView.reloadData();
    }
}
