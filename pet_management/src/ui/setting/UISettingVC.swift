//
//  UISettingVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/25.
//

import UIKit;

class UISettingVC: UITableViewController {
    @IBOutlet var settingTableView: UITableView!;
    @IBOutlet var profilePhotoImageView: UIImageView!;
    @IBOutlet var nicknameLabel: UILabel!;
    var accountDetail: Account?;
    var accountPhoto: UIImage?;
    
    override func viewDidLoad() {
        self.loadAccountDetails();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ProfileShowSegue") {
            let vc = segue.destination as! UIProfileVC;
            vc.accountDetail = self.accountDetail;
            vc.accountPhoto = self.accountPhoto;
        }
        if (segue.identifier == "SettingGeoTagShowSegue") {
            let vc = segue.destination as! UISettingGeoTagVC;
            vc.currentSearchRange = self.accountDetail!.mapSearchRadius;
        }
    }
    
    func loadAccountDetails() {
        AccountUtil.reqHttpFetchAccount(resume: false, sender: self) {
            (res) in
            self.accountDetail = AccountUtil.getAccountFromFetchedDto(dto: res.value!);
            self.nicknameLabel.text = self.accountDetail!.nickname;
            self.loadAccountPhoto();
        }
    }
    
    func loadAccountPhoto() {
        AccountUtil.reqHttpFetchAccountPhoto(accountId: self.accountDetail!.id, sender: self) {
            (res) in
            let photo = UIImage(data: res.data!);
            if(photo != nil) {
                self.accountPhoto = photo;
            } else {
                self.accountPhoto = UIImage(named: "ICBaselinePets60WithPadding");
            }
            self.profilePhotoImageView.image = self.accountPhoto;
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section) {
        case 0:
            guard (self.accountDetail != nil && self.accountPhoto != nil) else {
                return;
            }
            switch (indexPath.row) {
            case 0:
                self.performSegue(withIdentifier: "ProfileShowSegue", sender: self);
            default:
                return;
            }
        case 1:
            switch (indexPath.row) {
            case 0:
                self.performSegue(withIdentifier: "SettingGeoTagShowSegue", sender: self);
            case 1:
                self.performSegue(withIdentifier: "SettingNotificationShowSegue", sender: self);
            case 2:
                return;
            default:
                return;
            }
        case 2:
            switch (indexPath.row) {
            case 0:
                self.performSegue(withIdentifier: "PrivacyShowSegue", sender: self);
            case 1:
                self.performSegue(withIdentifier: "TermsShowSegue", sender: self);
            case 2:
                self.performSegue(withIdentifier: "LicenseShowSegue", sender: self);
            case 3:
                return;
            default:
                return;
            }
        default:
            return;
        }
    }
}
