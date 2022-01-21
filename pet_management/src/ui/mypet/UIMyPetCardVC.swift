//
//  UIMyPetCardVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/21.
//

import UIKit;

class UIMyPetCardVC: UIViewController {
    @IBOutlet weak var petNameLabel: UILabel!;
    @IBOutlet weak var petBreedLabel: UILabel!;
    @IBOutlet weak var petAgeLabel: UILabel!;
    @IBOutlet weak var petGenderLabel: UILabel!;
    @IBOutlet weak var petMessageLabel: UILabel!;
    @IBOutlet weak var petImage: UIImageView!;
    @IBOutlet weak var petRepresentitiveImage: UIImageView!;
    
    var accountDetail: [String: Any]?;
    var pet: Pet?;
    
    convenience init (pet: Pet) {
        self.init();
        self.pet = pet;
    }
    
    override func viewDidLoad() {
        if (self.pet != nil) {
            self.petNameLabel.text = self.pet!.name;
            self.petBreedLabel.text = self.pet!.breed;
            self.petAgeLabel.text = self.convertAge(birth: self.pet!.birth);
            self.petGenderLabel.text = self.convertGender(gender: self.pet!.gender);
            self.petMessageLabel.text = self.pet!.message;
            self.petImage.image = self.convertImage(photoUrl: self.pet!.photoUrl);
        }
        
        self.accountDetail = try! JSONSerialization.jsonObject(with: UserDefaults.standard.object(forKey: "loginAccountDetail") as! Data, options: []) as! [String: Any];
        
        if (self.accountDetail!["representativePetId"] != nil) {
            self.petRepresentitiveImage.isHidden = (self.accountDetail!["representativePetId"] as! Int) != self.pet?.id;
        }
    }
    
    func convertAge(birth: String) -> String {
        // extrude year from datestring
        let birthYear = Int(birth.prefix(4));
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "yyyy";
        let currentYear = Int(dateFormatter.string(from: Date()));
        let age = currentYear! - birthYear!;
        return String(age);
    }
    
    func convertGender(gender: Bool) -> String {
        return gender ? "♀" : "♂";
    }
    
    func convertImage(photoUrl: String?) -> UIImage {
        if (photoUrl == nil) {
            return UIImage(named: "ICBaselinePets60WithPadding")!;
        } else {
            var imgData: Data;
            do {
                imgData = try Data(contentsOf: URL(string: photoUrl!)!);
            } catch {
                return UIImage(named: "ICBaselinePets60WithPadding")!;
            }
            return UIImage(data: imgData)!;
        }
    }
}
