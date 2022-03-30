//
//  UIProfileVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/28.
//

import UIKit;

class UIProfileVC: UIViewController {
    @IBOutlet weak var profilePhotoImageView: UIImageView!;
    @IBOutlet weak var nicknameTextField: UITextField!;
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
        self.nicknameTextField.text = self.accountDetail!.nickname;
        self.emailTextField.text = self.accountDetail!.email;
        self.phoneTextField.text = self.accountDetail!.phone;
        self.marketingSwitch.isOn = self.accountDetail!.marketing;
    }
    
    func verifyAccountDetails() -> Bool {
        guard (AccountUtil.validateUsernameInput(username: self.nicknameTextField.text!)) else {
            self.present(UIUtil.makeSimplePopup(title: "프로필 수정 에러", message: "닉네임은 5자 이상 20자 이하여야 합니다", onClose: nil), animated: true);
            return false;
        }
        guard (AccountUtil.validateEmailInput(email: self.emailTextField.text!)) else {
            self.present(UIUtil.makeSimplePopup(title: "프로필 수정 에러", message: "이메일 양식이 유효하지 않습니다", onClose: nil), animated: true);
            return false;
        }
        guard (AccountUtil.validatePhoneInput(phone: self.phoneTextField.text!)) else {
            self.present(UIUtil.makeSimplePopup(title: "프로필 수정 에러", message: "전화번호는 '-'를 포함한 유효한 양식이어야 합니다", onClose: nil), animated: true);
            return false;
        }
        return true;
    }
    
    // Action Methods
    @IBAction func updateProfileBtnOnClick(_ sender: UIBarButtonItem) {
        if (verifyAccountDetails()) {
            AccountUtil.reqHttpUpdateAccount(email: self.emailTextField.text, phone: self.phoneTextField.text, marketing: self.marketingSwitch.isOn, nickname: self.nicknameTextField.text, sender: self) {
                (res) in
                self.performSegue(withIdentifier: "SettingUnwindSegue", sender: self);
            }
        }
    }
    @IBAction func changePasswordBtnOnClick(_ sender: UIButton) {
        let alertController = UIAlertController(title: "비밀번호 변경", message: "계정 비밀번호를 변경합니다", preferredStyle: .alert);
        alertController.addTextField(configurationHandler: {
            (textfield) in
            textfield.placeholder = "현재 비밀번호";
            textfield.isSecureTextEntry = true;
        });
        alertController.addTextField(configurationHandler: {
            (textfield) in
            textfield.placeholder = "변경할 비밀번호";
            textfield.isSecureTextEntry = true;
        });
        alertController.addTextField(configurationHandler: {
            (textfield) in
            textfield.placeholder = "변경할 비밀번호 확인";
            textfield.isSecureTextEntry = true;
        });
        alertController.addAction(UIAlertAction(title: "비밀번호 변경", style: .default) {
            (action) in
            guard (AccountUtil.validatePasswordInput(password: alertController.textFields![1].text!)) else {
                self.present(UIUtil.makeSimplePopup(title: "비밀번호 변경 오류", message: "비밀번호는 8~20글자 이내여야 합니다", onClose: nil), animated: true);
                return;
            }
            guard (alertController.textFields![1].text == alertController.textFields![2].text) else {
                self.present(UIUtil.makeSimplePopup(title: "비밀번호 변경 오류", message: "비밀번호가 일치하지 않습니다", onClose: nil), animated: true);
                return;
            }
            AccountUtil.reqHttpUpdateAccountPassword(password: alertController.textFields![0].text!, newPassword: alertController.textFields![1].text!, sender: self) {
                (res) in
                self.present(UIUtil.makeSimplePopup(title: "비밀번호 변경", message: "비밀번호가 변경되었습니다", onClose: nil), animated: true);
            }
        });
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel));
        self.present(alertController, animated: true);
    }
    @IBAction func logoutBtnOnClick(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "loginToken");
        UserDefaults.standard.removeObject(forKey: "loginAccountDetail");
        UserDefaults.standard.removeObject(forKey: "myPetList");
        self.performSegue(withIdentifier: "LogoutUnwindSegue", sender: self);
    }
    @IBAction func deleteUserBtnOnClick(_ sender: UIButton) {
        let alertController = UIAlertController(title: "회원탈퇴", message: "정말로 회원탈퇴하시겠습니까? 계정이 삭제되면 모든 게시물과 반려동물 정보가 삭제되며, 절대로 복구할 수 없습니다", preferredStyle: .alert);
        alertController.addAction(UIAlertAction(title: "회원탈퇴", style: .destructive) {
            (handler) in
            AccountUtil.reqHttpDeleteAccount(accountId: self.accountDetail!.id, sender: self) {
                (res) in
                UserDefaults.standard.removeObject(forKey: "loginToken");
                UserDefaults.standard.removeObject(forKey: "loginAccountDetail");
                UserDefaults.standard.removeObject(forKey: "myPetList");
                self.performSegue(withIdentifier: "LogoutUnwindSegue", sender: self);
            }
        });
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel));
        self.present(alertController, animated: true);
    }
}
