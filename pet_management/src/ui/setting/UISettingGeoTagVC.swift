//
//  UISettingGeoTagVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/28.
//

import UIKit;

class UISettingGeoTagVC: UITableViewController {
    @IBOutlet weak var geoTagSwitch: UISwitch!;
    @IBOutlet weak var searchRangeButton: UIButton!;
    @IBOutlet weak var searchRangeLabel: UILabel!;
    
    var currentSearchRange: Double?;
    
    override func viewDidLoad() {
        self.setupSearchRangeBtn();
    }
    
    func setupSearchRangeBtn() {
        let searchRange: KeyValuePairs = [
            "1km": 1000.0,
            "2km": 2000.0,
            "5km": 5000.0,
            "10km": 10000.0,
            "15km": 15000.0,
            "20km": 20000.0,
            "25km": 25000.0,
            "30km": 30000.0,
            "40km": 40000.0,
            "50km": 50000.0,
            "60km": 60000.0,
            "70km": 70000.0,
            "80km": 80000.0,
            "90km": 90000.0,
            "100km": 100000.0,
            "150km": 150000.0,
            "200km": 200000.0,
            "250km": 250000.0,
            "300km": 300000.0,
            "400km": 400000.0,
            "500km": 500000.0
        ];
        let searchRangeMenu = searchRange.map({
            (range) in
            return UIAction(title: range.key) {
                _ in
                AccountUtil.reqHttpUpdateAccount(mapSearchRadius: range.value, sender: self) {
                    (res) in
                    self.searchRangeButton.setTitle(range.key, for: .normal);
                }
            };
        });
        self.searchRangeButton.menu = UIMenu(title:"", children: searchRangeMenu);
        self.searchRangeButton.setTitle("\(Int(self.currentSearchRange ?? 0.0) / 1000)km", for: .normal);
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 1) {
            self.searchRangeButton.sendActions(for: .touchUpInside);
        }
    }
    
    @IBAction func geoTagSwitchOnChange(_ sender: UISwitch) {
        if (self.geoTagSwitch.isOn) {
            self.searchRangeLabel.textColor = .label;
            self.searchRangeButton.isEnabled = true;
            AccountUtil.reqHttpUpdateAccount(mapSearchRadius: 50000.0, sender: self) {
                (res) in
                self.searchRangeButton.setTitle("50km", for: .normal);
            }
        } else {
            self.searchRangeLabel.textColor = .lightGray;
            self.searchRangeButton.isEnabled = false;
            AccountUtil.reqHttpUpdateAccount(mapSearchRadius: 0.0, sender: self) {
                (res) in
                self.searchRangeButton.setTitle("0km", for: .normal);
            }
        }
        
    }
}
