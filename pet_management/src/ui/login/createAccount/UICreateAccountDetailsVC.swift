//
//  UICreateAccountDetailsVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/15.
//

import UIKit
import Alamofire;

class UICreateAccountDetailsVC : UIViewController {
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
    var isEmailVerified = false;
    var verificationTimeLeft = 600;
    var verificationTimer: Timer?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Initialize button status and label visiblity
        self.sendCodeBtn.isEnabled = false;
        self.changeEmailBtn.isEnabled = false;
        self.createAccountBtn.isEnabled = false;
        self.errorLabel.text = "";
        self.timeLimitLabel.isHidden = true;
        self.verifyCodeTextField.isEnabled = false;
    }
    
    // objc func onTimerFires
    // No Param
    // Return Void
    // Update verification time left on every second
    @objc func onTimerFires() {
        if (self.verificationTimeLeft == 0) {
            self.timeoutTimeLimitTimer();
        }
        self.verificationTimeLeft -= 1;
        self.timeLimitLabel.text = "남은 시간: \(self.verificationTimeLeft / 60):\(self.verificationTimeLeft % 60)";
    }
    
    // func validatePhoneInput
    // No Param
    // Return Bool - validity of input
    // Validate phone number input
    func validatePhoneInput() -> Bool {
        let regex = "(^02|^\\d{3})-(\\d{3}|\\d{4})-\\d{4}";
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", regex);
        return phonePredicate.evaluate(with: self.phoneTextField.text);
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
        self.errorLabel.text = self.phoneErrorMsg + self.emailErrorMsg;
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
    
    // func checkRequeirementsForCreateAccount
    // No Param
    // Return Void
    // Check requirements if there is no problem to request to verify verification code and create account
    func checkRequirementsForCreateAccount() {
        if (self.validatePhoneInput() && self.validateEmailInput() && self.verificationTimer != nil && self.verificationTimer!.isValid) {
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
        self.startTimeLimitTimer();
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
        self.stopTimeLimitTimer();
    }
    
    // func startTimeLimitTimer
    // No Param
    // Return Void
    // Initialize verificiation timelimit timer & start counting
    func startTimeLimitTimer() {
        if self.verificationTimer != nil && self.verificationTimer!.isValid {
            self.verificationTimer!.invalidate();
        }
        self.verificationTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true);
        self.timeLimitLabel.isHidden = false;
        self.timeLimitLabel.text = "남은 시간: 10:00";
        self.verificationTimeLeft = 600;
    }
    
    // func stopTimeLimitTimer
    // No Param
    // Return Void
    // Stop verificiation timelimit timer & reset verification time left
    func stopTimeLimitTimer() {
        if (self.verificationTimer != nil) {
            self.verificationTimer?.invalidate();
        }
        self.timeLimitLabel.isHidden = true;
        self.verificationTimeLeft = 600;
    }
    
    // func timeoutTimeLimitTimer
    // No Param
    // Return Void
    // Alert timeout & call func stopTimeLimitTimer
    func timeoutTimeLimitTimer() {
        self.resetVerifyProcess();
        // Notify timeout by opening popup
        let alertController = UIAlertController(title: "이메일 인증 시간 초과",
                                                message: "이메일 인증에 실패하였으니 다시 시도해 주십시오",
                                                preferredStyle: .alert);
        let approveAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default);
        alertController.addAction(approveAction);
        self.present(alertController, animated: true, completion: nil);
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
                self.showHttpErrorPopup(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                self.resetVerifyProcess();
                return;
            }
            
            guard (res.value?._metadata.status == true) else {
                self.showHttpErrorPopup(reqApi: reqApi, errMsg: res.value?._metadata.message);
                self.resetVerifyProcess();
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
                self.showHttpErrorPopup(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                self.resetVerifyProcess();
                return;
            }
            guard (res.value?._metadata.status == true) else {
                // Do not reset verify process when user entered wrong verify code to give retry change for user
                self.showHttpErrorPopup(reqApi: reqApi, errMsg: res.value?._metadata.message);
                return;
            }
            self.isEmailVerified = true;
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
        
        AF.request(reqUrl, method: .post, parameters: self.paramDict, encoding: JSONEncoding.default).responseDecodable(of: CreateAccountDto.self) {
            (res) in
            guard (res.error == nil) else {
                self.showHttpErrorPopup(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                self.resetVerifyProcess();
                return;
            }
            guard (res.value?._metadata.status == true) else {
                self.showHttpErrorPopup(reqApi: reqApi, errMsg: res.value?._metadata.message);
                self.resetVerifyProcess();
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
        let alertController = UIAlertController(title: "회원가입 완료",
                                                message: "환영합니다. 회원가입이 완료되었으니 로그인 하십시오",
                                                preferredStyle: .alert);
        let approveAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) {
            (action) in
            self.performSegue(withIdentifier: "CreateAccountDetailsUnwindSegue", sender: action);
        };
        alertController.addAction(approveAction);
        self.present(alertController, animated: true, completion: nil);
    }
    
    // func showHttpErrorPopup
    // Param - reqApi: String - the api method which is failed to process
    // Param - errMsg: String - the error message sent from backend or HTTP protocol
    // Return Void
    // Show error message popup when api call failed
    func showHttpErrorPopup(reqApi: String, errMsg: String?) {
        // TODO: API 요청 에러 핸들링 더 깔끔하게 할 방법 찾아보기
        print("=================================================");
        print("API Request Failure : \(reqApi)");
        print(errMsg ?? "Unknown Error");
        print("=================================================");
        let alertController = UIAlertController(title: "네트워크 요청 에러",
                                                message: errMsg ?? "Unknown Error",
                                                preferredStyle: .alert);
        let approveAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default);
        alertController.addAction(approveAction);
        self.present(alertController, animated: true, completion: nil);
    }
    
    // func showToast
    // Param - message: String - the message which is displayed at toast
    // Return Void
    // Show toast message with given string
    func showToast(message : String) {
        // TODO: 별도의 utility class로 분리하여 커스텀 UI 객체처럼 토스트 알림 라이브러리를 만들어 사용하기
        // Toast messsage view position setting
        let width_variable:CGFloat = 10;
        let toastLabel = UILabel(frame: CGRect(x: width_variable, y: self.view.frame.size.height-100, width: view.frame.size.width-2*width_variable, height: 35));
        
        // Toast message style setting
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6);
        toastLabel.textColor = UIColor.white;
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 10.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        
        // Toast message appear
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    
    
    // Action Methods
    @IBAction func phoneTextFieldOnChange(_ sender: UITextField) {
        if (self.validatePhoneInput()) {
            self.phoneErrorMsg = "";
        } else {
            self.phoneErrorMsg = "전화번호는 '-'를 포함한 유효한 양식이어야 합니다\n"
        }
        self.updateErrorMessage();
        self.checkRequirementsForVerification();
        self.checkRequirementsForCreateAccount();
    }
    
    @IBAction func emailTextFieldOnChange(_ sender: UITextField) {
        if (self.validateEmailInput()) {
            self.emailErrorMsg = "";
        } else {
            self.emailErrorMsg = "이메일 양식이 유효하지 않습니다\n"
        }
        self.isEmailVerified = false;
        self.updateErrorMessage();
        self.checkRequirementsForVerification();
        self.checkRequirementsForCreateAccount();
    }
    
    @IBAction func sendCodeBtnOnClick(_ sender: UIButton) {
        if (self.verificationTimer != nil && self.verificationTimer!.isValid) {
            self.resetVerifyProcess();
        }
        self.startVerifyProcess();
        self.showToast(message: "해당 이메일 주소로 인증 코드를 발송했습니다");
        self.reqHttpSendVerificationEmail();
        self.checkRequirementsForCreateAccount();
    }
    
    @IBAction func changeEmailBtnOnClick(_ sender: UIButton) {
        self.resetVerifyProcess();
    }
    
    @IBAction func createAccountBtnOnClick(_ sender: UIBarButtonItem) {
        self.reqHttpVerifyCode();
    }
}
