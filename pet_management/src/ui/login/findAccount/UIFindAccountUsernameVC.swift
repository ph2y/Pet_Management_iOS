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
                self.showHttpErrorPopup(reqApi: reqApi, errMsg: res.error?.localizedDescription);
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
        let alertController = UIAlertController(title: "아이디 찾기 오류",
                                                message:"입력하신 이메일 주소로 회원가입된 계정이 없습니다",
                                                preferredStyle: .alert);
        let approveAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default);
        alertController.addAction(approveAction);
        self.present(alertController, animated: true, completion: nil);
    }
    
    // func showFindUsernameSuccessPopup
    // No Param
    // Return Void
    // Show success notice popup with founded username
    func showFindUsernameSuccessPopup(foundUsername: String) {
        let alertController = UIAlertController(title:"아이디 찾기", message:"회원님의 로그인 아이디는 \(foundUsername) 입니다", preferredStyle: .alert);
        let approveAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) {
            (action) in
            self.performSegue(withIdentifier: "FoundAccountUsernameSegue", sender: action);
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
