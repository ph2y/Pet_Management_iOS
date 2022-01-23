//
//  UIMyPetEditorVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/23.
//

import UIKit;
import PhotosUI;
import Foundation;
import Alamofire;

class UIMyPetEditorVC: UIViewController {
    @IBOutlet weak var petImageView: UIImageView!;
    @IBOutlet weak var petMsgTextView: UITextView!;
    @IBOutlet weak var petNameTextField: UITextField!;
    @IBOutlet weak var petGenderSwitch: UISwitch!;
    @IBOutlet weak var petSpiciesTextField: UITextField!;
    @IBOutlet weak var petBreedTextField: UITextField!;
    @IBOutlet weak var petBirthPicker: UIDatePicker!;
    @IBOutlet weak var petYearOnlySwitch: UISwitch!;
    @IBOutlet weak var deletePetBtn: UIBarButtonItem!;
    
    var imagePickerConf = PHPickerConfiguration();
    var imagePicker: PHPickerViewController?;
    
    var pet: Pet?;
    var isNewPet: Bool = true;
    
    override func viewDidLoad() {
        // Setup image picker
        self.imagePickerConf.selectionLimit = 1;
        self.imagePickerConf.filter = .images;
        self.imagePicker = PHPickerViewController(configuration: self.imagePickerConf);
        if (self.imagePicker != nil) {
            self.imagePicker!.delegate = self;
        }
        
        // Hide deletePetBtn if user creating a new pet
        if (self.isNewPet) {
            self.deletePetBtn.isEnabled = false;
            self.deletePetBtn.tintColor = UIColor.clear;
        } else {
            self.petNameTextField.text = self.pet!.name;
            self.petSpiciesTextField.text = self.pet!.species;
            self.petBreedTextField.text = self.pet!.breed;
            self.petMsgTextView.text = self.pet!.message;
            self.petGenderSwitch.isOn = self.pet!.gender;
            self.petBirthPicker.date = PetUtil.convertBirthToDate(birth: self.pet!.birth);
        }
    }
    
    func verifyPetDetails() -> Bool {
        if(self.petNameTextField.text!.count > 0 &&
        self.petNameTextField.text!.count <= 20 &&
        self.petSpiciesTextField.text!.count <= 200 &&
        self.petBreedTextField.text!.count <= 200 &&
           self.petMsgTextView.text!.count <= 200) {
            return true;
        } else {
            self.present(UIUtil.makeSimplePopup(title: "오류", message: "반려동물의 이름은 1~20자 이내, 반려동물의 종, 품종과 상태 메시지는 200자 이내여야 합니다", onClose: nil), animated: true);
            return false;
        }
    }
    
    func reqHttpCreatePet() {
        let reqApi = "pet/create";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        
        reqBody["name"] = self.petNameTextField.text;
        reqBody["species"] = self.petSpiciesTextField.text;
        reqBody["breed"] = self.petBreedTextField.text;
        reqBody["birth"] = PetUtil.convertBirthToString(birth: self.petBirthPicker.date);
        reqBody["yearOnly"] = String(self.petYearOnlySwitch.isOn);
        reqBody["gender"] = String(self.petGenderSwitch.isOn);
        reqBody["message"] = self.petMsgTextView.text;
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PetCreateDto.self) {
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
            // self.reqHttpUpdatePetPhoto();
            
            self.performSegue(withIdentifier: "FinishCreatePetUnwindSegue", sender: self);
        }
    }
    
    func reqHttpUpdatePet() {
        let reqApi = "pet/update";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        
        reqBody["id"] = String(self.pet!.id);
        reqBody["name"] = self.petNameTextField.text;
        reqBody["species"] = self.petSpiciesTextField.text;
        reqBody["breed"] = self.petBreedTextField.text;
        reqBody["birth"] = PetUtil.convertBirthToString(birth: self.petBirthPicker.date);
        reqBody["yearOnly"] = String(self.petYearOnlySwitch.isOn);
        reqBody["gender"] = String(self.petGenderSwitch.isOn);
        reqBody["message"] = self.petMsgTextView.text;
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PetCreateDto.self) {
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
            // self.reqHttpUpdatePetPhoto();
            
            self.performSegue(withIdentifier: "FinishUpdatePetUnwindSegue", sender: self);
        }
    }
    
    func reqHttpDeletePet() {
        let reqApi = "pet/delete";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        
        reqBody["id"] = String(self.pet!.id);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PetDeleteDto.self) {
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
            
            self.performSegue(withIdentifier: "FinishCreatePetUnwindSegue", sender: self);
        }
    }
    
    // Action Methods
    @IBAction func changePetImageBtnOnClick(_ sender: UIButton) {
        if (self.imagePicker != nil) {
            self.present(self.imagePicker!, animated: true);
        }
    }
    @IBAction func saveBtnOnClick(_ sender: UIButton) {
        guard self.verifyPetDetails() else {
            return;
        }
        if (self.isNewPet) {
            self.reqHttpCreatePet();
        } else {
            self.reqHttpUpdatePet();
        }
    }
    @IBAction func deleteBtnOnClick(_ sender: UIButton) {
        // Check before pet delete operation by opening popup
        let alertController = UIAlertController(title: nil,
                                                message: "정말로 반려동물 정보를 삭제하시겠습니까?",
                                                preferredStyle: .alert);
        let approveAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { (action) in
            self.reqHttpDeletePet();
        };
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel);
        alertController.addAction(approveAction);
        alertController.addAction(cancelAction);
        self.present(alertController, animated: true, completion: nil);
    }
}

// Petphoto image selector extension
extension UIMyPetEditorVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true);
        let itemProvider = results.first?.itemProvider;
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) {
                (image, error) in
                DispatchQueue.main.async {
                    self.petImageView.image = image as? UIImage;
                }
            }
        } else {
            // If user select nothing or load photo from gallery operation failure
            self.petImageView.image = UIImage(named: "ICBaselinePets60WithPadding")!;
        }
    }
}
