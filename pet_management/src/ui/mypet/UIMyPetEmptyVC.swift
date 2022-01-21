//
//  UIMyPetEmptyVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/21.
//

import UIKit;

class UIMyPetEmptyVC: UIViewController {
    @IBOutlet weak var noPetLabel: UILabel!;
    
    var isMyPetEmpty: Bool?;
    
    convenience init(isEmpty: Bool) {
        self.init();
        self.isMyPetEmpty = isEmpty;
    }
    
    override func viewDidLoad() {
        if (self.isMyPetEmpty != nil) {
            self.noPetLabel.isHidden = !(self.isMyPetEmpty!);
        }
    }
}
