//
//  UIMyPetCardVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/21.
//

import UIKit;

class UIMyPetCardVC: UIViewController {
    @IBOutlet weak var petCardView: UIView!
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
        // Setup user details
        self.accountDetail = try! JSONSerialization.jsonObject(with: UserDefaults.standard.object(forKey: "loginAccountDetail") as! Data, options: []) as! [String: Any];
        
        // Display pet details
        if (self.pet != nil) {
            self.petNameLabel.text = self.pet!.name;
            self.petBreedLabel.text = self.pet!.breed;
            self.petAgeLabel.text = PetUtil.convertAge(birth: self.pet!.birth);
            self.petGenderLabel.text = PetUtil.convertGender(gender: self.pet!.gender);
            self.petMessageLabel.text = self.pet!.message;
            self.petImage.image = PetUtil.convertImage(photoUrl: self.pet!.photoUrl);
            self.showRepresentitiveImage();
        }
        
        // Setup tap gesture
        let gesture = UITapGestureRecognizer(target: self, action: #selector(UIMyPetCardVC.showDetailPage(_:)));
        self.petCardView.addGestureRecognizer(gesture);
    }
    
    @objc func showDetailPage(_ sender: UIGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let myPetDetailVC = storyboard.instantiateViewController(withIdentifier: "MyPetDetail") as! UIMyPetDetailVC;
        myPetDetailVC.pet = self.pet;
        self.navigationController!.pushViewController(myPetDetailVC, animated: true);
    }
    
    func showRepresentitiveImage() {
        if (self.accountDetail!["representativePetId"] != nil) {
            guard (!(self.accountDetail!["representativePetId"]! is NSNull)) else {
                self.petRepresentitiveImage.isHidden = true;
                return;
            }
            self.petRepresentitiveImage.isHidden = (self.accountDetail!["representativePetId"] as! Int) != self.pet?.id;
        }
    }
}
