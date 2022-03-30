//
//  UICreateAccountDetailsVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/15.
//

import UIKit;
import Alamofire;

class UICreateAccountDetailsVC: UIViewController {
    @IBOutlet weak var createAccountBtn: UIBarButtonItem!
    @IBOutlet weak var phoneTextField: UITextField!;
    @IBOutlet weak var emailTextField: UITextField!;
    @IBOutlet weak var sendCodeBtn: UIButton!;
    @IBOutlet weak var changeEmailBtn: UIButton!;
    @IBOutlet weak var errorLabel:UILabel!;
    @IBOutlet weak var verifyCodeTextField: UITextField!;
    @IBOutlet weak var timeLimitLabel: UILabel!;
    
    var paramDict = Dictionary<String, String>();
    var phoneErrorMsg = "";
    var emailErrorMsg = "";
    var verificationTimer: EmailVerificationTimer?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Initialize button status and label visiblity
        self.sendCodeBtn.isEnabled = false;
        self.changeEmailBtn.isEnabled = false;
        self.createAccountBtn.isEnabled = false;
        self.errorLabel.text = "";
        self.timeLimitLabel.isHidden = true;
        self.verifyCodeTextField.isEnabled = false;
        
        // Initialize Timer
        self.verificationTimer = EmailVerificationTimer(
            timerFireHandler: {
                (leftTimeStr: String) in
                self.timeLimitLabel.text = "남은 시간: \(leftTimeStr)";
            },
            timeoutHandler: {
                self.resetVerifyProcess();
                // Notify timeout by opening popup
                self.present(UIUtil.makeSimplePopup(title: "이메일 인증 시간 초과",
                                                    message: "이메일 인증에 실패하였으니 다시 시도해 주십시오",
                                                    onClose: nil), animated: true, completion: nil);
            }
        );
    }
    
    
    
    // func updateErrorMessage
    // No Param
    // Return Void
    // Update error message
    func updateErrorMessage() {
        self.errorLabel.text = self.phoneErrorMsg + self.emailErrorMsg;
    }
    
    // func checkRequirementsForVerification
    // No Param
    // Return Void
    // Check requirements if there is no problem to request to send verification email
    func checkRequirementsForVerification() {
        if (AccountUtil.validateEmailInput(email: self.emailTextField.text!)) {
            self.sendCodeBtn.isEnabled = true;
        } else {
            self.sendCodeBtn.isEnabled = false;
        }
    }
    
    // func checkRequeirementsForCreateAccount
    // No Param
    // Return Void
    // Check requirements if there is no problem to request to verify verification code and create account
    func checkRequirementsForCreateAccount() {
        if (AccountUtil.validatePhoneInput(phone: self.phoneTextField.text!) && AccountUtil.validateEmailInput(email: self.emailTextField.text!) && self.verificationTimer!.isTimerRunning()) {
            self.createAccountBtn.isEnabled = true;
        } else {
            self.createAccountBtn.isEnabled = false;
        }
    }
    
    // func startVerifyProcess
    // No Param
    // Return Void
    // Initialize verifyCodeTextField
    // Prevent unpredict email address change
    // Start verificiation timelimit timer
    func startVerifyProcess() {
        self.emailTextField.isEnabled = false;
        self.verifyCodeTextField.text = "";
        self.verifyCodeTextField.isEnabled = true;
        self.changeEmailBtn.isEnabled = true;
        self.verificationTimer!.startTimeLimitTimer() {
            (leftTimeStr: String) in
            self.timeLimitLabel.isHidden = false;
            self.timeLimitLabel.text = "남은 시간: \(leftTimeStr)";
        };
    }
    
    // func resetVerifyProcess
    // No Param
    // Return Void
    // Initialize verifyCodeTextField
    // Allow user can change email
    // Stop verificiation timelimit timer
    func resetVerifyProcess() {
        self.emailTextField.isEnabled = true;
        self.verifyCodeTextField.text = "";
        self.verifyCodeTextField.isEnabled = false;
        self.changeEmailBtn.isEnabled = false;
        self.verificationTimer!.stopTimeLimitTimer() {
            () in
            self.timeLimitLabel.isHidden = true;
        };
    }
    
    // func reqHttpSendVerificiationEmail
    // No Param
    // Return Void
    // Request to the backend to send verification email to email address which user input
    func reqHttpSendVerificationEmail() {
        let reqApi = "account/authcode/send";
        let reqUrl = "\(APIBackendConfig.host.rawValue)\(reqApi)";
        var reqBody = Dictionary<String, String>();
        reqBody["email"] = self.emailTextField.text;
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default).responseDecodable(of: AccountSendAuthCodeDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                self.resetVerifyProcess();
                self.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            
            guard (res.value?._metadata.status == true) else {
                self.resetVerifyProcess();
                self.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
        };
    }
    
    // func reqHttpVerifyCode
    // No Param
    // Return Void
    // Request to the backend to check verification code is valid
    func reqHttpVerifyCode() {
        let reqApi = "account/authcode/verify";
        let reqUrl = "\(APIBackendConfig.host.rawValue)\(reqApi)";
        var reqBody = Dictionary<String, String>();
        reqBody["email"] = self.emailTextField.text;
        reqBody["code"] = self.verifyCodeTextField.text;

        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default).responseDecodable(of: AccountVerifyAuthCodeDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                self.resetVerifyProcess();
                self.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            guard (res.value?._metadata.status == true) else {
                // Do not reset verify process when user entered wrong verify code to give retry change for user
                self.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
            self.reqHttpCreateAccount();
        }
    }
    
    // func reqHttpCreateAccount
    // No Param
    // Return Void
    // Request to the backend to create new account by the user input
    func reqHttpCreateAccount() {
        let reqApi = "account/create";
        let reqUrl = "\(APIBackendConfig.host.rawValue)\(reqApi)";
        self.paramDict["phone"] = self.phoneTextField.text;
        self.paramDict["email"] = self.emailTextField.text;
        self.paramDict["nickname"] = self.paramDict["username"];
        self.paramDict["userMessage"] = "";
        self.paramDict["notification"] = "true";
        
        AF.request(reqUrl, method: .post, parameters: self.paramDict, encoding: JSONEncoding.default).responseDecodable(of: AccountCreateDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                self.resetVerifyProcess();
                self.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            guard (res.value?._metadata.status == true) else {
                self.resetVerifyProcess();
                self.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
            self.showCreateAccountSuccessPopup();
        }
    }
    
    // func showCreateAccountSuccessPopup
    // No Param
    // Return Void
    // Show popup with create account success message
    // Unwind to UILoginVC
    func showCreateAccountSuccessPopup() {
        self.present(UIUtil.makeSimplePopup(title: "회원가입 완료",
                                                 message: "환영합니다. 회원가입이 완료되었으니 로그인 하십시오") {
            (action) in
            self.performSegue(withIdentifier: "CreateAccountDetailsUnwindSegue", sender: action);
        }, animated: true);
    }
    
    // Action Methods
    @IBAction func phoneTextFieldOnChange(_ sender: UITextField) {
        if (AccountUtil.validatePhoneInput(phone: self.phoneTextField.text!)) {
            self.phoneErrorMsg = "";
        } else {
            self.phoneErrorMsg = "전화번호는 '-'를 포함한 유효한 양식이어야 합니다\n"
        }
        self.updateErrorMessage();
        self.checkRequirementsForVerification();
        self.checkRequirementsForCreateAccount();
    }
    
    @IBAction func emailTextFieldOnChange(_ sender: UITextField) {
        if (AccountUtil.validateEmailInput(email: self.emailTextField.text!)) {
            self.emailErrorMsg = "";
        } else {
            self.emailErrorMsg = "이메일 양식이 유효하지 않습니다\n"
        }
        self.updateErrorMessage();
        self.checkRequirementsForVerification();
        self.checkRequirementsForCreateAccount();
    }
    
    @IBAction func sendCodeBtnOnClick(_ sender: UIButton) {
        if (self.verificationTimer != nil && self.verificationTimer!.isTimerRunning()) {
            self.resetVerifyProcess();
        }
        self.startVerifyProcess();
        UIUtil.showToast(view: self.view, message: "해당 이메일 주소로 인증 코드를 발송했습니다");
        self.reqHttpSendVerificationEmail();
        self.checkRequirementsForCreateAccount();
    }
    
    @IBAction func changeEmailBtnOnClick(_ sender: UIButton) {
        self.resetVerifyProcess();
    }
    
    @IBAction func createAccountBtnOnClick(_ sender: UIBarButtonItem) {
        self.createAccountBtn.isEnabled = false;
        self.reqHttpVerifyCode();
    }
}
