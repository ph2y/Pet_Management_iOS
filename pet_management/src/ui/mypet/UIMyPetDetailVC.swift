//
//  UIMyPetDetailVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/23.
//

import UIKit;
import Alamofire;

class UIMyPetDetailVC: UIViewController {
    @IBOutlet weak var petNameLabel: UILabel!;
    @IBOutlet weak var petAgeLabel: UILabel!;
    @IBOutlet weak var petGenderLabel: UILabel!;
    @IBOutlet weak var petImage: UIImageView!;
    
    var pet: Pet?;
    
    override func viewDidLoad() {
        if (self.pet != nil) {
            self.showPetDetails();
        }
    }
    
    func showPetDetails() {
        self.petNameLabel.text = self.pet!.name;
        self.petAgeLabel.text = "\(PetUtil.convertAge(birth: self.pet!.birth))살";
        self.petGenderLabel.text = PetUtil.convertGender(gender: self.pet!.gender);
        self.petImage.image = PetUtil.convertImage(photoUrl: self.pet!.photoUrl);
    }
    
    func renewPetDetails() {
        let reqApi = "pet/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["id"] = String(self.pet!.id);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PetFetchDto.self) {
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
            
            self.pet = res.value?.petList?[0];
            self.showPetDetails();
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "MyPetEditSegue") {
            let destVC = segue.destination;
            guard let myPetEditorVC = destVC as? UIMyPetEditorVC else {
                return;
            }
            myPetEditorVC.pet = self.pet;
            myPetEditorVC.isNewPet = false;
        }
    }
    
    // Action Methods
    @IBAction func unwindToMyPetDetail(_ segue: UIStoryboardSegue) {
        self.renewPetDetails();
    }
}
