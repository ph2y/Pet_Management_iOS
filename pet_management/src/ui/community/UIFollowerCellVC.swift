//
//  UIFollowerCellVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/23.
//

import UIKit;

class UIFollowerCellVC: UITableViewCell {
    @IBOutlet weak var accountPhotoImageView: UIImageView!;
    @IBOutlet weak var nicknameLabel: UILabel!;
    
    var followAccount: Account?;
    var senderVC: UIViewController?;
    
    func initCell() {
        guard (self.followAccount != nil && self.senderVC != nil) else {
            return;
        }
        
        // load username(nickname)
        self.nicknameLabel.text = self.followAccount!.nickname;
        
        // load representative pet's profile photo (if no pet -> show default)
        if (self.followAccount?.photoUrl != nil) {
            AccountUtil.reqHttpFetchAccountPhoto(accountId: self.followAccount!.id, sender: self.senderVC!) {
                (res) in
                self.accountPhotoImageView.image = UIImage(data: res.data!);
            }
        } else {
            self.accountPhotoImageView.image = UIImage(named: "ICBaselinePets60WithPadding")!;
        }
    }
}
