//
//  LoginViewController.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/14.
//

import UIKit
import Alamofire;

class UILoginVC: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!;
    @IBOutlet weak var passwordTextField: UITextField!;

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
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
            self.performSegue(withIdentifier: "LoginAccountSegue", sender: self);
        }
    }
    
    @IBAction func unwindToLogin(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func loginBtnOnClick(_ sender: UIButton) {
        self.reqHttpLogin();
    }

}
