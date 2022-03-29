//
//  UIProfileVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/28.
//

import UIKit;

class UIProfileVC: UIViewController {
    @IBOutlet weak var profilePhotoImageView: UIImageView!;
    @IBOutlet weak var nicknameTestField: UITextField!;
    @IBOutlet weak var emailTextField: UITextField!;
    @IBOutlet weak var phoneTextField: UITextField!;
    @IBOutlet weak var marketingSwitch: UISwitch!;
    
    var accountDetail: Account?;
    var accountPhoto: UIImage?;
    
    override func viewDidLoad() {
        if (self.accountDetail != nil) {
            self.loadAccountDetails();
        }
    }
    
    func loadAccountDetails() {
        self.profilePhotoImageView.image = self.accountPhoto;
        self.nicknameTestField.text = self.accountDetail!.nickname;
        self.emailTextField.text = self.accountDetail!.email;
        self.phoneTextField.text = self.accountDetail!.phone;
        self.marketingSwitch.isOn = self.accountDetail!.marketing;
    }
    
    func verifyAccountDetails() -> Bool {
        
        return true;
    }
    
    // Action Methods
    @IBAction func updateProfileBtnOnClick(_ sender: UIBarButtonItem) {
        if (verifyAccountDetails()) {
            
        }
    }
    @IBAction func changePasswordBtnOnClick(_ sender: UIButton) {
    }
    @IBAction func logoutBtnOnClick(_ sender: UIButton) {
    }
    @IBAction func deleteUserBtnOnClick(_ sender: UIButton) {
    }
}
