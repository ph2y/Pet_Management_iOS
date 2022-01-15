//
//  UICreateAccountCredentialsVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/15.
//

import UIKit

class UICreateAccountCredentialsVC : UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!;
    @IBOutlet weak var passwordTextField: UITextField!;
    @IBOutlet weak var passwordCheckTextField: UITextField!;
    @IBOutlet weak var nextStepBtn: UIBarButtonItem!;
    @IBOutlet weak var errorLabel: UILabel!;
    var paramMarketing: Bool?;
    var usernameErrorMsg = "";
    var passwordErrorMsg = "";
    var passwordCheckErrorMsg = "";
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // Initialize button status (default: disabled) and errorLabel status (default: emptyString)
        self.nextStepBtn.isEnabled = false;
        self.errorLabel.text = "";
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination;
        guard let destVC = dest as? UICreateAccountDetailsVC else {
            return;
        }
        var paramDict = Dictionary<String, String>();
        paramDict["username"] = self.usernameTextField.text;
        paramDict["password"] = self.passwordTextField.text;
        paramDict["marketing"] = String(self.paramMarketing!);
        
        destVC.paramDict = paramDict;
    }
    
    // func valicateUsernameInput
    // No Param
    // Return Bool - validity of input
    // Check username input is valid for api requirement
    func validateUsernameInput() -> Bool {
        return 5 <= self.usernameTextField.text!.count && self.usernameTextField.text!.count <= 20;
    }
    
    // func validatePasswordInput
    // No Param
    // Return Bool - validity of input
    // Check password input is valid for api requirement
    func validatePasswordInput() -> Bool {
        return 8 <= self.passwordTextField.text!.count && self.passwordTextField.text!.count <= 20;
    }
    
    // func validatePasswordCheckInput
    // No Param
    // Return Bool - validity of input
    // Check password check input is equal to password input for prevent account password setup mistakes
    func validatePasswordCheckInput() -> Bool {
        return self.passwordTextField.text == self.passwordCheckTextField.text;
    }
    
    // func updateErrorMassage
    // No Param
    // Return Void
    // Update error message
    func updateErrorMessage() {
        self.errorLabel.text = self.usernameErrorMsg + self.passwordErrorMsg + self.passwordCheckErrorMsg;
    }
    
    // func checkRequirementsForNextStep
    // No Param
    // Return Void
    // Check user input is all valid
    func checkRequirementsForNextStep() {
        if (self.validateUsernameInput() && self.validatePasswordInput() && self.validatePasswordCheckInput()) {
            self.nextStepBtn.isEnabled = true;
        } else {
            self.nextStepBtn.isEnabled = false;
        }
    }
    
    // Action Methods
    @IBAction func usernameTextFieldOnChange(_ sender: UITextField) {
        if (self.validateUsernameInput()) {
            self.usernameErrorMsg = "";
        } else {
            self.usernameErrorMsg = "아이디는 5~20글자 이내여야 합니다\n";
        }
        self.updateErrorMessage();
        self.checkRequirementsForNextStep();
    }
    @IBAction func passwordTextFieldOnChange(_ sender: UITextField) {
        if (self.validatePasswordInput()) {
            self.passwordErrorMsg = "";
        } else {
            self.passwordErrorMsg = "비밀번호는 8~20글자 이내여야 합니다\n";
        }
        if (self.validatePasswordCheckInput()) {
            self.passwordCheckErrorMsg = "";
        } else {
            self.passwordCheckErrorMsg = "비밀번호가 일치하지 않습니다";
        }
        self.updateErrorMessage();
        self.checkRequirementsForNextStep();
    }
    @IBAction func passwordCheckTextFieldOnChange(_ sender: UITextField) {
        if (self.validatePasswordCheckInput()) {
            self.passwordCheckErrorMsg = "";
        } else {
            self.passwordCheckErrorMsg = "비밀번호가 일치하지 않습니다";
        }
        self.updateErrorMessage();
        self.checkRequirementsForNextStep();
    }
}
