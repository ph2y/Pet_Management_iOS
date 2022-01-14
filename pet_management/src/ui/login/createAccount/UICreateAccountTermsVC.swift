//
//  UICreateAccountTermsVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/14.
//

import UIKit

class UICreateAccountTermsVC : UIViewController {
    @IBAction func cancelCreateAccountBtnOnClick(_ sender: Any) {
        // 팝업창 객체
        let alertController = UIAlertController(title: nil,
                                                message: "회원가입을 취소하고 로그인 화면으로 돌아가시겠습니까?",
                                                preferredStyle: .alert);

        // 확인 버튼 객체
        let approveAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { (action) in
            self.performSegue(withIdentifier: "CreateAccountUnwindSegue", sender: action)
        }

        // 취소 버튼 객체
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel);

        // 팝업창에 버튼 추가
        alertController.addAction(approveAction);
        alertController.addAction(cancelAction);
        
        // 팝업창 표출
        self.present(alertController, animated: true, completion: nil);
    }
}
