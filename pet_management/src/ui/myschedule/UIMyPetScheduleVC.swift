//
//  UIMyPetScheduleVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/24.
//

import UIKit;
import Alamofire;

protocol UIMyPetScheduleDelegate {
    func scheduleStateChanged();
}

class UIMyPetScheduleVC: UIViewController, UIMyPetScheduleDelegate {
    @IBOutlet weak var scheduleListTableView: UITableView!;
    var scheduleList: [PetSchedule] = [];
    
    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true;
        self.scheduleListTableView.separatorInset = UIEdgeInsets.zero;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.reqHttpFetchPetSchedule();
    }
    
    // func scheduleStateChanged
    // No Param
    // Return Void
    // Call syncScheduleNotification when schedule enable switch is tapped
    func scheduleStateChanged() {
        self.syncScheduleNotification();
    }
    
    // func syncScheduleNotification
    // No Param
    // Return Void
    // Sync notifications with enabled schedules
    func syncScheduleNotification() {
        // Check notification already set
        UNUserNotificationCenter.current().getPendingNotificationRequests() {
            (notiList) in
            for notification in notiList {
                if (notification.identifier.contains("pet_schedule_")) {
                    let schedule: PetSchedule? = self.scheduleList.first(where: {
                        (schedule) in
                        notification.identifier.split(separator: "_")[2] == String(schedule.id);
                    });
                    
                    if (schedule == nil) {
                        // Cancel pending notification if schedule not exist
                        var identifierList: [String] = [];
                        identifierList.append(notification.identifier);
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifierList);
                    } else if (!(schedule!.enabled)) {
                        // Cancel pending notification if disabled schedule's notification is set
                        var identifierList: [String] = [];
                        identifierList.append("pet_schedule_\(schedule!.id)");
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifierList);
                    }
                }
            }
        }
        // Check notification not set yet
        for schedule in scheduleList {
            UNUserNotificationCenter.current().getPendingNotificationRequests() {
                (notiList) in
                if (!notiList.contains(where: {
                    (notification) in
                    notification.identifier == "pet_schedule_\(schedule.id)";
                })) {
                    // Setup notification if enabled schedule's notification is not set
                    if (schedule.enabled) {
                        self.setupNewNotificaton(schedule: schedule);
                    }
                };
            }
        }
    }
    
    // func setupNewNotification
    // No Param
    // Return Void
    // Send user notification for reminder
    func setupNewNotificaton(schedule: PetSchedule) {
        guard(UserDefaults.standard.bool(forKey: "notiPerm")) else {
            self.present(UIUtil.makeSimplePopup(
                title: "알림 권한 오류", message: "알림 권한을 허용하여야 리마인더 추가가 가능합니다", onClose: nil
            ), animated: true);
            return;
        }
        let content = UNMutableNotificationContent();
        var petNameListStr = "";
        schedule.petList.forEach() {
            (pet) in
            petNameListStr += "\(pet.name) ";
        };
        content.title = "집사의 노트";
        content.subtitle = petNameListStr;
        content.body = schedule.memo;
        content.badge = 1;
        content.sound = UNNotificationSound.default;
        
        let scheduleDate = PetScheduleUtil.convertTimeToDate(timeString: schedule.time);
        var scheduleDateComponent = DateComponents();
        scheduleDateComponent.hour = Calendar.current.component(.hour, from: scheduleDate);
        scheduleDateComponent.minute = Calendar.current.component(.minute, from: scheduleDate);
        let trigger = UNCalendarNotificationTrigger(dateMatching: scheduleDateComponent, repeats: true);
        let request = UNNotificationRequest(identifier: "pet_schedule_\(schedule.id)", content: content, trigger: trigger);
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil);
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
            self.syncScheduleNotification();
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
            cell.delegate = self;
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
