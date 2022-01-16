//
//  UICreateAccountTermsVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/14.
//

import UIKit

class UICreateAccountTermsVC: UIViewController {
    @IBOutlet weak var agreeAllSwitch: UISwitch!;
    @IBOutlet weak var agreeTermSwitch: UISwitch!;
    @IBOutlet weak var agreePrivacySwitch: UISwitch!;
    @IBOutlet weak var agreeMarketingSwitch: UISwitch!;
    @IBOutlet weak var nextStepBtn: UIBarButtonItem!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Initialize UISwitches status (default: off)
        agreeAllSwitch.setOn(false, animated: true);
        self.turnOffAllUISwitch();
        
        // Initialize nextStepBtn status (default: disabled)
        nextStepBtn.isEnabled = false;
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination;
        guard let destVC = dest as? UICreateAccountCredentialsVC else {
            return;
        }
        
        destVC.paramMarketing = self.agreeMarketingSwitch.isOn;
    }
    
    // func turnOffAllUISwitch
    // No Param
    // Return Void
    // Turn off all UISwitches except agreeAll UISwitch
    func turnOffAllUISwitch() {
        self.agreeTermSwitch.setOn(false, animated: true);
        self.agreePrivacySwitch.setOn(false, animated: true);
        self.agreeMarketingSwitch.setOn(false, animated: true);
    }
    
    // func turnOnAllUISwitch
    // No Param
    // Return Void
    // Turn on all UISwitches except agreeAll UISwitch
    func turnOnAllUISwitch() {
        self.agreeTermSwitch.setOn(true, animated: true);
        self.agreePrivacySwitch.setOn(true, animated: true);
        self.agreeMarketingSwitch.setOn(true, animated: true);
    }
    
    // func syncUserAgreeAllUISwitch
    // No Param
    // Return Void
    // Sync agreeAll UISwitch if user turned on all UISwitch manually
    func syncUserAgreeAllUISwitch() {
        if (self.agreeTermSwitch.isOn && self.agreePrivacySwitch.isOn && self.agreeMarketingSwitch.isOn) {
            self.agreeAllSwitch.setOn(true, animated: true);
        } else {
            self.agreeAllSwitch.setOn(false, animated: true);
        }
    }
    
    // func checkRequirementsForNextStep
    // No Param
    // Return Void
    // Check user agreed all essential terms
    func checkRequirementsForNextStep() {
        if (self.agreeTermSwitch.isOn && self.agreePrivacySwitch.isOn) {
            self.nextStepBtn.isEnabled = true;
        } else {
            self.nextStepBtn.isEnabled = false;
        }
    }
    
    // Action Methods
    @IBAction func cancelBtnOnClick(_ sender: Any) {
        // Check before cancel create account operation by opening popup
        let alertController = UIAlertController(title: nil,
                                                message: "회원가입을 취소하고 로그인 화면으로 돌아가시겠습니까?",
                                                preferredStyle: .alert);
        let approveAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { (action) in
            self.performSegue(withIdentifier: "CreateAccountUnwindSegue", sender: action);
        };
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel);
        alertController.addAction(approveAction);
        alertController.addAction(cancelAction);
        self.present(alertController, animated: true, completion: nil);
    }
    @IBAction func agreeAllSwitchOnClick(_ sender: UISwitch) {
        if (sender.isOn) {
            // Turn on all switches when user enable agreeAll UISwitch
            self.turnOnAllUISwitch();
        } else {
            // Turn off all switches when user disable agreeAll UISwitch
            self.turnOffAllUISwitch();
        }
        
        self.checkRequirementsForNextStep();
    }
    @IBAction func agreeTermsSwitchOnClick(_ sender: Any) {
        self.checkRequirementsForNextStep();
        self.syncUserAgreeAllUISwitch();
    }
    @IBAction func agreePrivacySwitchOnClick(_ sender: Any) {
        self.checkRequirementsForNextStep();
        self.syncUserAgreeAllUISwitch();
    }
    @IBAction func agreeMarketingSwitchOnClick(_ sender: Any) {
        self.syncUserAgreeAllUISwitch();
    }
}
