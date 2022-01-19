//
//  UIFindAccountUsernameVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/16.
//

import UIKit
import Alamofire

class UIFindAccountUsernameVC: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!;
    @IBOutlet weak var errorLabel: UILabel!;
    @IBOutlet weak var findAccountUsernameBtn: UIButton!;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialzie ErrorLabel & FindButton
        self.errorLabel.text = "";
        self.findAccountUsernameBtn.isEnabled = false;
    }
    
    // func validateEmailInput
    // No Param
    // Return Bool - validity of input
    // Validate email address input
    func validateEmailInput() -> Bool {
        // TODO: 코드의 중복도 낮출 방법 고려해보기. 본 메소드를 유틸리티 클래스로 뺀다거나~
        let regex = "[A-Z0-9a-z_-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}";
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", regex);
        return emailPredicate.evaluate(with: self.emailTextField.text);
    }
    
    // func checkRequirementsForFindUsername
    // No Param
    // Return Void
    // Check requirements if there is no problem to request to find username
    func checkRequirementsForFindUsername() {
        if (self.validateEmailInput()) {
            self.findAccountUsernameBtn.isEnabled = true;
        } else {
            self.findAccountUsernameBtn.isEnabled = false;
        }
    }
    
    // func reqHttpFindAccountUsername
    // No Param
    // Return Void
    // Request to the backend to reset account username
    func reqHttpFindAccountUsername() {
        let reqApi = "account/recoverUsername";
        let reqUrl = "\(APIBackendConfig.host.rawValue)\(reqApi)";
        var reqBody = Dictionary<String, String>();
        reqBody["email"] = self.emailTextField.text;
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default).responseDecodable(of: AccountRecoverUsernameDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                self.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            guard (res.value != nil && res.value?.username != nil) else {
                self.showFindUsernameFailurePopup();
                return;
            }
            self.showFindUsernameSuccessPopup(foundUsername: res.value!.username!);
        }
    }
    
    // func showFindUsernameFailurePopup
    // No Param
    // Return Void
    // Show failure notice popup when account does not exist
    func showFindUsernameFailurePopup() {
        self.present(UIUtil.makeSimplePopup(title: "아이디 찾기 오류",
                                                 message:"입력하신 이메일 주소로 회원가입된 계정이 없습니다",
                                                 onClose: nil), animated: true);
    }
    
    // func showFindUsernameSuccessPopup
    // No Param
    // Return Void
    // Show success notice popup with founded username
    func showFindUsernameSuccessPopup(foundUsername: String) {
        self.present(UIUtil.makeSimplePopup(title:"아이디 찾기",
                                                 message:"회원님의 로그인 아이디는 \(foundUsername) 입니다") {
            (action) in
            self.performSegue(withIdentifier: "FoundAccountUsernameSegue", sender: action);
        }, animated: true);
    }
    
    // Action Methods
    @IBAction func emailTextFieldOnChange(_ sender: UITextField) {
        if (self.validateEmailInput()) {
            self.errorLabel.text = "";
        } else {
            self.errorLabel.text = "이메일 양식이 유효하지 않습니다";
        }
        self.checkRequirementsForFindUsername();
    }
    @IBAction func findAccountUsernameBtnOnClick(_ sender: UIButton) {
        self.reqHttpFindAccountUsername();
    }
}
