//
//  UIFindAccountPasswordVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/16.
//

import UIKit;
import Alamofire;

class UIFindAccountPasswordVC: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!;
    @IBOutlet weak var emailTextField: UITextField!;
    @IBOutlet weak var verifyCodeTextField: UITextField!;
    @IBOutlet weak var errorLabel: UILabel!;
    @IBOutlet weak var timeLimitLabel: UILabel!;
    @IBOutlet weak var sendCodeBtn: UIButton!;
    @IBOutlet weak var changeEmailBtn: UIButton!;
    @IBOutlet weak var findAccountPasswordBtn: UIButton!;
    
    var verificationTimer: EmailVerificationTimer?;
    var usernameErrorMsg = "";
    var emailErrorMsg = "";
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Initialize button status and label visiblity
        self.sendCodeBtn.isEnabled = false;
        self.changeEmailBtn.isEnabled = false;
        self.findAccountPasswordBtn.isEnabled = false;
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
                                                         onClose: nil), animated: true);
            }
        );
    }
    
    // func valicateUsernameInput
    // No Param
    // Return Bool - validity of input
    // Check username input is valid for api requirement
    func validateUsernameInput() -> Bool {
        return 5 <= self.usernameTextField.text!.count && self.usernameTextField.text!.count <= 20;
    }
    
    // func validateEmailInput
    // No Param
    // Return Bool - validity of input
    // Validate email address input
    func validateEmailInput() -> Bool {
        let regex = "[A-Z0-9a-z_-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}";
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", regex);
        return emailPredicate.evaluate(with: self.emailTextField.text);
    }
    
    // func updateErrorMessage
    // No Param
    // Return Void
    // Update error message
    func updateErrorMessage() {
        self.errorLabel.text = self.usernameErrorMsg + self.emailErrorMsg;
    }
    
    // func checkRequirementsForVerification
    // No Param
    // Return Void
    // Check requirements if there is no problem to request to send verification email
    func checkRequirementsForVerification() {
        if (self.validateEmailInput()) {
            self.sendCodeBtn.isEnabled = true;
        } else {
            self.sendCodeBtn.isEnabled = false;
        }
    }
    
    // func checkRequeirementsForFindPassword
    // No Param
    // Return Void
    // Check requirements if there is no problem to request to find password
    func checkRequirementsForFindPassword() {
        if (self.validateUsernameInput() && self.validateEmailInput() && self.verificationTimer!.isTimerRunning()) {
            self.findAccountPasswordBtn.isEnabled = true;
        } else {
            self.findAccountPasswordBtn.isEnabled = false;
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
    
    // func reqHttpFindAccountPassword
    // No Param
    // Return Void
    // Request to the backend to reset account password
    func reqHttpFindAccountPassword() {
        let reqApi = "account/recoverPassword";
        let reqUrl = "\(APIBackendConfig.host.rawValue)\(reqApi)";
        var reqBody = Dictionary<String, String>();
        reqBody["username"] = self.usernameTextField.text;
        reqBody["code"] = self.verifyCodeTextField.text;
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default).responseDecodable(of: AccountRecoverPasswordDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                self.resetVerifyProcess();
                self.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            guard (res.value?._metadata.status == true) else {
                self.showFindPasswordFailurePopup();
                return;
            }
            self.showFindPasswordSuccessPopup();
        }
    }
    
    // func showFindPasswordFailurePopup
    // No Param
    // Return Void
    // Show failure notice popup when account does not exist or email verification failed
    func showFindPasswordFailurePopup() {
        self.present(UIUtil.makeSimplePopup(title: "비밀번호 찾기 오류",
                                                 message:"입력하신 아이디로 회원가입된 계정이 없거나 이메일 인증 코드가 틀립니다",
                                                 onClose: nil), animated: true);
    }
    
    // func showFindPasswordSuccessPopup
    // No Param
    // Return Void
    // Show success notice popup when password reset email sent
    func showFindPasswordSuccessPopup() {
        self.present(UIUtil.makeSimplePopup(title:"비밀번호 찾기",
                                                 message:"회원님의 이메일 주소로 임시 비밀번호를 발송하였으니, 해당 비밀번호로 로그인 하신 뒤 재설정 하십시오"){
            (action) in
            self.performSegue(withIdentifier: "FoundAccountPasswordSegue", sender: action);
        }, animated: true);
    }
    
    
    
    // Action Methods
    @IBAction func usernameTextFieldOnChange(_ sender: UITextField) {
        if (self.validateUsernameInput()) {
            self.usernameErrorMsg = "";
        } else {
            self.usernameErrorMsg = "아이디는 5~20글자 이내여야 합니다\n";
        }
        self.updateErrorMessage();
        self.checkRequirementsForFindPassword();
    }
    @IBAction func emailTextFieldOnChange(_ sender: UITextField) {
        if (self.validateEmailInput()) {
            self.emailErrorMsg = "";
        } else {
            self.emailErrorMsg = "이메일 양식이 유효하지 않습니다\n";
        }
        self.updateErrorMessage();
        self.checkRequirementsForVerification();
        self.checkRequirementsForFindPassword();
    }
    @IBAction func sendCodeBtnOnClick(_ sender: UIButton) {
        if (self.verificationTimer != nil && self.verificationTimer!.isTimerRunning()) {
            self.resetVerifyProcess();
        }
        self.startVerifyProcess();
        UIUtil.showToast(view: self.view, message: "해당 이메일 주소로 인증 코드를 발송했습니다");
        self.reqHttpSendVerificationEmail();
        self.checkRequirementsForFindPassword();
    }
    @IBAction func changeEmailBtnOnClick(_ sender: UIButton) {
        self.resetVerifyProcess();
    }
    @IBAction func findAccountPasswordBtnOnClick(_ sender: UIButton) {
        self.findAccountPasswordBtn.isEnabled = false;
        self.reqHttpFindAccountPassword();
    }
}
