//
//  UIMyPetScheduleCardVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/24.
//

import UIKit;
import Alamofire;

class UIMyPetScheduleCardVC: UIViewController {
    @IBOutlet weak var scheduleCardView: UIView!;
    @IBOutlet weak var scheduleAmPmLabel: UILabel!;
    @IBOutlet weak var scheduleTimeLabel: UILabel!;
    @IBOutlet weak var schedulePetNameLabel: UILabel!;
    @IBOutlet weak var scheduleMessageLabel: UILabel!;
    @IBOutlet weak var scheduleSwitch: UISwitch!;
    
    var schedule: PetSchedule?;
    var scheduleTime: Date?;
    
    override func viewDidLoad() {
        guard (self.schedule != nil) else {
            return;
        }
        
        // Display schedule details
        self.scheduleTime = PetScheduleUtil.convertTimeToDate(timeString: self.schedule!.time);
        self.scheduleAmPmLabel.text = PetScheduleUtil.evaluateScheduleAmPm(timeString: self.schedule!.time);
        self.scheduleTimeLabel.text = PetScheduleUtil.convertTimeToStringWithoutSecond(timeDate: self.scheduleTime!);
        self.schedulePetNameLabel.text = PetScheduleUtil.convertPetName(petList: self.schedule!.petList);
        self.scheduleMessageLabel.text = self.schedule!.memo;
        self.scheduleSwitch.isOn = self.schedule!.enabled;
        
        // Setup tap gesture
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.showEditorPage(_:)));
        self.scheduleCardView.addGestureRecognizer(gesture);
    }
    
    @objc func showEditorPage(_ sender: UIGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let myPetScheduleEditorVC = storyboard.instantiateViewController(withIdentifier: "MyPetScheduleEditor") as! UIMyPetScheduleEditorVC;
        myPetScheduleEditorVC.schedule = self.schedule;
        self.navigationController!.pushViewController(myPetScheduleEditorVC, animated: true);
    }
    
    func reqHttpUpdatePetSchedule() {
        let reqApi = "pet/schedule/update";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader = APIBackendUtil.getAuthHeader();
        reqBody["id"] = String(self.schedule!.id);
        reqBody["petIdList"] = self.schedule!.petIdList;
        reqBody["time"] = self.schedule!.time;
        reqBody["memo"] = self.schedule!.memo;
        reqBody["enabled"] = String(self.scheduleSwitch.isOn);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PetScheduleUpdateDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                self.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            
            guard (res.value?._metadata.status == true) else {
                self.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
        }
    }
    
    // Action Methods
    @IBAction func scheduleSwitchOnClick(_ sender: UISwitch) {
        self.reqHttpUpdatePetSchedule();
    }
}
