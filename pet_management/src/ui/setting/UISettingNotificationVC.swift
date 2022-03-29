//
//  UISettingNotificationVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/28.
//

import UIKit;

class UISettingNotificationVC: UITableViewController {
    @IBOutlet weak var communityAllNotificationSwitch: UISwitch!;
    @IBOutlet weak var communityCommentNotificationSwitch: UISwitch!;
    @IBOutlet weak var communityLikeNotificationSwitch: UISwitch!;
    @IBOutlet weak var communityFollowNotificationSwitch: UISwitch!;
    
    var accountDetails: Account?;
    
    override func viewDidLoad() {
        if (accountDetails != nil) {
            self.communityAllNotificationSwitch.isOn = accountDetails!.notification;
            self.syncCommunityNotiSwitches();
        }
    }
    
    func syncCommunityNotiSwitches() {
        self.communityCommentNotificationSwitch.isOn = self.communityAllNotificationSwitch.isOn;
        self.communityLikeNotificationSwitch.isOn = self.communityAllNotificationSwitch.isOn;
        self.communityFollowNotificationSwitch.isOn = self.communityAllNotificationSwitch.isOn;
    }
    
    // Action Methods
    @IBAction func communityAllNotiSwitchOnChange(_ sender: UISwitch) {
        AccountUtil.reqHttpUpdateAccount(notification: self.communityAllNotificationSwitch.isOn, sender: self) {
            (res) in
            // Sync subcategory switches
            self.syncCommunityNotiSwitches();
        }
    }
}
