//
//  UIMyPetScheduleEditorVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/24.
//

import UIKit;

class UIMyPetScheduleEditorVC: UIViewController {
    @IBOutlet weak var deleteScheduleBtn: UIBarButtonItem!;
    @IBOutlet weak var scheduleTimePicker: UIDatePicker!;
    @IBOutlet weak var schedulePetListTableView: UITableView!;
    @IBOutlet weak var scheduleMessageTextView: UITextView!;
    
    var myPetList: [Pet]?;
    var schedule: PetSchedule?;
    var isNewSchedule: Bool = true;
    
    override func viewDidLoad() {
        if (self.isNewSchedule) {
            self.deleteScheduleBtn.isEnabled = false;
            self.deleteScheduleBtn.tintColor = UIColor.clear;
        } else {
            self.scheduleTimePicker.date = PetScheduleUtil.convertTimeToDate(timeString: self.schedule!.time);
            self.scheduleMessageTextView.text = self.schedule!.memo;
            
            self.schedulePetListTableView.delegate = self;
            self.schedulePetListTableView.dataSource = self;
        }
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "petEmpty") else {
                fatalError("petEmptyReuseableCell not exist");
            }
            return cell;
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "petName") else {
                fatalError("petNameReuseableCell not exist");
            }
            var content = cell.defaultContentConfiguration();
            content.text = self.myPetList![indexPath.row].name;
            cell.contentConfiguration = content;
            return cell;
        }
    }
    
    
}
