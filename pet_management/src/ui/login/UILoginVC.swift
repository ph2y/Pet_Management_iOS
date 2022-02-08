//
//  LoginViewController.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/14.
//

import UIKit;
import Foundation;
import Alamofire;

class UILoginVC: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!;
    @IBOutlet weak var passwordTextField: UITextField!;

    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkPreviousCredentialValidity();
    }
    
    // func checkPreviousCredentialValidity
    // No Param
    // Return Void
    // Check auth token validity which is already saved at userdefaults
    func checkPreviousCredentialValidity() {
        guard (UserDefaults.standard.string(forKey: "loginToken") != nil) else {
            return;
        }
        self.reqHttpFetchAccount(resume: true);
    }
    
    // func reqHttpLogin
    // No Param
    // Return Void
    // Request login to the backend
    func reqHttpLogin() {
        let reqApi = "account/login";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        reqBody["username"] = self.usernameTextField.text;
        reqBody["password"] = self.passwordTextField.text;
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default).responseDecodable(of: AccountLoginDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                self.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            guard (res.value?._metadata.status == true && res.value?.token != nil) else {
                self.present(UIUtil.makeSimplePopup(title: "로그인 실패", message: "ID 또는 PW가 틀립니다", onClose: nil), animated: true);
                return;
            }
            UserDefaults.standard.set(res.value?.token, forKey: "loginToken");
            self.reqHttpFetchAccount(resume: false);
        }
    }
    
    // func reqHttpFetchAccount
    // Param resume: Bool - If true, application tries to reuse old auth token
    // Return Void
    // Fetch account infomation from backend and save to the userdefaults
    func reqHttpFetchAccount(resume: Bool) {
        let reqApi = "account/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        let reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = [
            "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "loginToken")!)"
        ];
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: AccountFetchDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                self.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            guard (res.value?._metadata.status == true) else {
                if (!resume) {
                    self.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                }
                return;
            }
            
            let loginAccountDetail: Dictionary<String, Any?> = [
                "id": res.value?.id,
                "username": res.value?.username,
                "email": res.value?.email,
                "phone": res.value?.phone,
                "marketing": res.value?.marketing,
                "nickname": res.value?.nickname,
                "photoUrl": res.value?.photoUrl,
                "userMessage": res.value?.userMessage,
                "representativePetId": res.value?.representativePetId,
                "fcmRegistrationToken": res.value?.fcmRegistrationToken,
                "notification": res.value?.notification
            ];
            
            if let data = try? JSONSerialization.data(withJSONObject: loginAccountDetail, options: []) {
                UserDefaults.standard.set(data, forKey: "loginAccountDetail");
                UserDefaults.standard.synchronize();
                self.performSegue(withIdentifier: "LoginAccountSegue", sender: self);
            }
        }
    }
    
    // Action Methods
    @IBAction func unwindToLogin(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func loginBtnOnClick(_ sender: UIButton) {
        self.reqHttpLogin();
    }
}
