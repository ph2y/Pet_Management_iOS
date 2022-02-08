//
//  UIMyPetScheduleVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/24.
//

import UIKit;
import Alamofire;

class UIMyPetScheduleVC: UIViewController {
    @IBOutlet weak var scheduleListTableView: UITableView!;
    var scheduleList: [PetSchedule] = [];
    
    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true;
        self.scheduleListTableView.separatorInset = UIEdgeInsets.zero;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.reqHttpFetchPetSchedule();
    }
    
    // func reqHttpFetchPetSchedule
    // No Param
    // Return Void
    // Request to the server to fetch pet schedule list
    func reqHttpFetchPetSchedule() {
        let reqApi = "pet/schedule/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        let reqBody = Dictionary<String, String>();
        let reqHeader = APIBackendUtil.getAuthHeader();
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PetScheduleFetchDto.self) {
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
            
            self.scheduleList = res.value?.petScheduleList ?? [];
            self.scheduleListTableView.delegate = self;
            self.scheduleListTableView.dataSource = nil;
            self.scheduleListTableView.dataSource = self;
        }
    }
    
    // Action Methods
    @IBAction func unwindToPetSchedule(_ segue: UIStoryboardSegue) {
        self.reqHttpFetchPetSchedule();
    }
}

extension UIMyPetScheduleVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.scheduleList.count != 0) {
            return self.scheduleList.count;
        } else {
            return 1;
        };
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.scheduleList.count == 0) {
            return tableView.dequeueReusableCell(withIdentifier: "petScheduleEmpty")!;
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "petSchedule") as! UIMyPetScheduleCellVC;
            cell.scheduleTimeLabel.text = PetScheduleUtil.convertTimeToStringWithoutSecond(timeDate: PetScheduleUtil.convertTimeToDate(timeString: self.scheduleList[indexPath.row].time));
            cell.scheduleAmPmLabel.text = PetScheduleUtil.evaluateScheduleAmPm(timeString: self.scheduleList[indexPath.row].time);
            cell.scheduleMessageLabel.text = self.scheduleList[indexPath.row].memo;
            cell.schedulePetNameLabel.text = PetScheduleUtil.convertPetName(petList: self.scheduleList[indexPath.row].petList);
            cell.scheduleEnabledSwitch.isOn = self.scheduleList[indexPath.row].enabled;
            cell.schedule = self.scheduleList[indexPath.row];
            return cell;
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let myPetScheduleDetailVC = storyboard.instantiateViewController(withIdentifier: "MyPetScheduleEditor") as! UIMyPetScheduleEditorVC;
        myPetScheduleDetailVC.schedule = self.scheduleList[indexPath.row];
        myPetScheduleDetailVC.isNewSchedule = false;
        tableView.deselectRow(at: indexPath, animated: true);
        self.navigationController!.pushViewController(myPetScheduleDetailVC, animated: true);
    }
}
