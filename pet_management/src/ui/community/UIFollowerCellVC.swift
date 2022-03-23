//
//  UIFollowerCellVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/23.
//

import UIKit;

class UIFollowerCellVC: UITableViewCell {
    @IBOutlet weak var representativePetPhotoImageView: UIImageView!;
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
        if (self.followAccount?.representativePetId != nil) {
            PetUtil.reqHttpFetchPetPhoto(petId: self.followAccount!.representativePetId!, sender: self.senderVC!) {
                (photo) in
                self.representativePetPhotoImageView.image = photo;
            }
        } else {
            self.representativePetPhotoImageView.image = UIImage(named: "ICBaselinePets60WithPadding")!;
        }
    }
}
