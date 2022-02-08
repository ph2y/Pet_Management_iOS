//
//  UIMyPetScheduleCellVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/28.
//

import UIKit;
import Alamofire;

class UIMyPetScheduleCellVC: UITableViewCell {
//    @IBOutlet weak var scheduleCellView: UIView!;
    @IBOutlet weak var scheduleTimeLabel: UILabel!;
    @IBOutlet weak var scheduleAmPmLabel: UILabel!;
    @IBOutlet weak var scheduleMessageLabel: UILabel!;
    @IBOutlet weak var schedulePetNameLabel: UILabel!;
    @IBOutlet weak var scheduleEnabledSwitch: UISwitch!;
    
    var schedule: PetSchedule?;
    
    // func reqHttpEnablePetSchedule
    // No Param
    // Return Void
    // Request to the server to enable pet schedule
    func reqHttpEnablePetSchedule() {
        let reqApi = "pet/schedule/update";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["id"] = String(self.schedule!.id);
        reqBody["petIdList"] = self.schedule!.petIdList;
        reqBody["time"] = self.schedule!.time;
        reqBody["memo"] = self.schedule!.memo;
        reqBody["enabled"] = String(self.scheduleEnabledSwitch.isOn);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PetScheduleUpdateDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                return;
            }
            
            guard (res.value?._metadata.status == true) else {
                return;
            }
        }
    }
    
    // Action Methods
    @IBAction func scheduleEnabledSwitchOnClick(_ sender: UISwitch) {
        guard (self.schedule != nil) else {
            return;
        }
        self.reqHttpEnablePetSchedule();
    }
}
