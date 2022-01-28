//
//  UIMyPetScheduleEditorVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/24.
//

import UIKit;
import Alamofire;

class UIMyPetScheduleEditorVC: UIViewController {
    @IBOutlet weak var deleteScheduleBtn: UIBarButtonItem!;
    @IBOutlet weak var scheduleTimePicker: UIDatePicker!;
    @IBOutlet weak var schedulePetListTableView: UITableView!;
    @IBOutlet weak var scheduleMessageTextView: UITextView!;
    
    var myPetList: [Pet]?;
    var schedule: PetSchedule?;
    var isNewSchedule: Bool = true;
    var selectedPetIDList = Set<Int>();
    
    override func viewDidLoad() {
        // Load pet list data
        if UserDefaults.standard.object(forKey: "myPetList") != nil {
            let data = UserDefaults.standard.value(forKey: "myPetList") as! Data;
            self.myPetList = try! PropertyListDecoder().decode([Pet].self, from: data);
        }
        
        // Load pet list table
        self.schedulePetListTableView.separatorInset = UIEdgeInsets.zero;
        self.schedulePetListTableView.delegate = self;
        self.schedulePetListTableView.dataSource = self;
        
        // Setup view content
        if (self.isNewSchedule) {
            // If user adds new schedule, hide delete btn
            self.deleteScheduleBtn.isEnabled = false;
            self.deleteScheduleBtn.tintColor = UIColor.clear;
        } else {
            // If user edits existing schedule, load current values
            self.scheduleTimePicker.date = PetScheduleUtil.convertTimeToDate(timeString: self.schedule!.time);
            self.scheduleMessageTextView.text = self.schedule!.memo;
            self.selectCurrentAppliedPet();
        }
    }
    
    func selectCurrentAppliedPet() {
        for (index, pet) in self.myPetList!.enumerated() {
            if (self.schedule?.petList[index].id == pet.id) {
                self.schedulePetListTableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.none);
            }
        }
    }
    
    func reqHttpCreatePetSchedule() {
        let reqApi = "pet/schedule/create";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        let sortedSelectedPetIdList = self.selectedPetIDList.sorted(by: { $0 < $1 });
        
        reqBody["petIdList"] = (sortedSelectedPetIdList.map{String($0)}).joined(separator: ",");
        reqBody["time"] = PetScheduleUtil.convertTimeToString(timeDate: self.scheduleTimePicker.date);
        reqBody["memo"] = self.scheduleMessageTextView.text;
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PetScheduleCreateDto.self) {
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
            self.performSegue(withIdentifier: "PetScheduleUnwindSegue", sender: self);
        }
    }
    
    func reqHttpUpdatePetSchedule() {
        let reqApi = "pet/schedule/update";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        let sortedSelectedPetIdList = self.selectedPetIDList.sorted(by: { $0 < $1 });
        
        reqBody["id"] = String(self.schedule!.id);
        reqBody["petIdList"] = (sortedSelectedPetIdList.map{String($0)}).joined(separator: ",");
        reqBody["time"] = PetScheduleUtil.convertTimeToString(timeDate: self.scheduleTimePicker.date);
        reqBody["memo"] = self.scheduleMessageTextView.text;
        reqBody["enabled"] = String(self.schedule!.enabled);
        
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
            self.performSegue(withIdentifier: "PetScheduleUnwindSegue", sender: self);
        }
    }
    
    func reqHttpDeletePetSchedule() {
        let reqApi = "pet/schedule/delete";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        
        reqBody["id"] = String(self.schedule!.id);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PetScheduleDeleteDto.self) {
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
            self.present(UIUtil.makeSimplePopup(title: "리마인더 삭제", message: "리마인더가 삭제되었습니다") {
                (action) in
                self.performSegue(withIdentifier: "PetScheduleUnwindSegue", sender: action);
            }, animated: true);
        }
    }
    
    // Action Methods
    @IBAction func savePetScheduleBtnOnClick(_ sender: UIBarButtonItem) {
        guard (!self.selectedPetIDList.isEmpty) else {
            self.present(UIUtil.makeSimplePopup(title: "리마인더 편집 오류", message: "최소한 1개 이상의 대상 반려동물을 선택하여야 합니다", onClose: nil), animated: true);
            return;
        }
        if (self.isNewSchedule) {
            self.reqHttpCreatePetSchedule();
        } else {
            self.reqHttpUpdatePetSchedule();
        }
    }
    @IBAction func deletePetScheduleBtnOnClick(_ sender: UIBarButtonItem) {
        // Check before pet delete operation by opening popup
        let alertController = UIAlertController(title: nil,
                                                message: "정말로 리마인더를 삭제하시겠습니까?",
                                                preferredStyle: .alert);
        let approveAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { (action) in
            self.reqHttpDeletePetSchedule();
        };
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel);
        alertController.addAction(approveAction);
        alertController.addAction(cancelAction);
        self.present(alertController, animated: true, completion: nil);
    }
}

extension UIMyPetScheduleEditorVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.myPetList!.count != 0) {
            return self.myPetList!.count;
        } else {
            return 1;
        };
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.myPetList!.count == 0) {
            return tableView.dequeueReusableCell(withIdentifier: "petEmpty")!;
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "petName")!;
            var content = cell.defaultContentConfiguration();
            content.text = self.myPetList![indexPath.row].name;
            cell.contentConfiguration = content;
            return cell;
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark;
        self.selectedPetIDList.insert(self.myPetList![indexPath.row].id);
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none;
        self.selectedPetIDList.remove(self.myPetList![indexPath.row].id);
    }
}
