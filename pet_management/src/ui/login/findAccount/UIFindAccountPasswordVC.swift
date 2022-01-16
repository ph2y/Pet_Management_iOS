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
                let alertController = UIAlertController(title: "이메일 인증 시간 초과",
                                                        message: "이메일 인증에 실패하였으니 다시 시도해 주십시오",
                                                        preferredStyle: .alert);
                let approveAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default);
                alertController.addAction(approveAction);
                self.present(alertController, animated: true, completion: nil);
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
                self.showHttpErrorPopup(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                self.resetVerifyProcess();
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
        let alertController = UIAlertController(title: "비밀번호 찾기 오류",
                                                message:"입력하신 아이디로 회원가입된 계정이 없거나 이메일 인증 코드가 틀립니다",
                                                preferredStyle: .alert);
        let approveAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default);
        alertController.addAction(approveAction);
        self.present(alertController, animated: true, completion: nil);
    }
    
    // func showFindPasswordSuccessPopup
    // No Param
    // Return Void
    // Show success notice popup when password reset email sent
    func showFindPasswordSuccessPopup() {
        let alertController = UIAlertController(title:"비밀번호 찾기", message:"회원님의 이메일 주소로 임시 비밀번호를 발송하였으니, 해당 비밀번호로 로그인 하신 뒤 재설정 하십시오", preferredStyle: .alert);
        let approveAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) {
            (action) in
            self.performSegue(withIdentifier: "FoundAccountPasswordSegue", sender: action);
        }
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
        // 1. print 하는 부분은 별도 메소드로 분리하고
        // 2. 얼럿을 띄우는 부분도 별도 메소드로 분리한다
        // 3. 네트워크 요청 에러가 아닌 정상적으로 요청이 접수되었으나 양식 검증에서 걸리는 등의 경우는 각각의 호출 메소드에서 해당 상황에 맞는 메시지를 팝업창을 띄워 표출 및 처리하도록 하자.
        // 반영 시점 -> 로그인/회원가입/IDPW찾기까지 다 구현한 다음에 바로 TODO 리팩토링
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
        self.showToast(message: "해당 이메일 주소로 인증 코드를 발송했습니다");
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
