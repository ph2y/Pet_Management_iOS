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
    @IBOutlet weak var savePetBtn: UIBarButtonItem!;
    @IBOutlet weak var changePetImageBtn: UIButton!;
    
    var imagePickerConf = PHPickerConfiguration();
    var imagePicker: PHPickerViewController?;
    
    var pet: Pet?;
    var newPetId: Int?;
    var isNewPet: Bool = true;
    var uploadPetImage: Bool = false;
    var deletePetImage: Bool = false;
    
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
            self.petYearOnlySwitch.isOn = self.pet!.yearOnly;
            self.petBirthPicker.date = PetUtil.convertBirthToDate(birth: self.pet!.birth);
            if (self.pet!.photoUrl == nil) {
                self.petImageView.image = UIImage(named: "ICBaselinePets60WithPadding")!;
            } else {
                PetUtil.reqHttpFetchPetPhoto(petId: self.pet!.id, sender: self) {
                    (petPhoto) in
                    self.petImageView.image = petPhoto;
                }
            }
        }
    }
    
    // func lockEditor
    // No Parmas
    // Return Void
    // Lock editor to prevent duplicate request while uploading photo
    func lockEditor() {
        self.petMsgTextView.isEditable = false;
        self.petNameTextField.isEnabled = false;
        self.petGenderSwitch.isEnabled = false;
        self.petSpiciesTextField.isEnabled = false;
        self.petBreedTextField.isEnabled = false;
        self.petBirthPicker.isEnabled = false;
        self.petYearOnlySwitch.isEnabled = false;
        if(!self.isNewPet) {
            self.deletePetBtn.isEnabled = false;
        }
        self.changePetImageBtn.isEnabled = false;
        self.savePetBtn.isEnabled = false;
    }
    
    // func unlockEditor
    // No Parmas
    // Return Void
    // Unlock editor after photo upload is finished or failed
    func unlockEditor() {
        self.petMsgTextView.isEditable = true;
        self.petNameTextField.isEnabled = true;
        self.petGenderSwitch.isEnabled = true;
        self.petSpiciesTextField.isEnabled = true;
        self.petBreedTextField.isEnabled = true;
        self.petBirthPicker.isEnabled = true;
        self.petYearOnlySwitch.isEnabled = true;
        if(!self.isNewPet) {
            self.deletePetBtn.isEnabled = true;
        }
        self.changePetImageBtn.isEnabled = true;
        self.savePetBtn.isEnabled = true;
    }
    
    // func verifyPetDetails
    // No Params
    // Return Bool - validity of user input
    // Verify user input(pet infomation) is valid
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
    
    // func reqHttpCreatePet
    // No Params
    // Return Void
    // Request to the server to create new pet entity
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
            self.newPetId = res.value!.id;
            if (self.uploadPetImage) {
                self.lockEditor();
                self.reqHttpUpdatePetPhoto();
            } else if (self.deletePetImage) {
                self.reqHttpDeletePetPhoto();
            } else {
                self.performSegue(withIdentifier: "FinishCreatePetUnwindSegue", sender: self);
            }
        }
    }
    
    // func reqHttpUpdatePet
    // No Params
    // Return Void
    // Request to the server to update pet infomation
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
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PetUpdateDto.self) {
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
            
            if (self.uploadPetImage) {
                self.lockEditor();
                self.reqHttpUpdatePetPhoto();
            } else if (self.deletePetImage) {
                self.reqHttpDeletePetPhoto();
            } else {
                self.performSegue(withIdentifier: "FinishUpdatePetUnwindSegue", sender: self);
            }
        }
    }
    
    // func reqHttpDeletePet
    // No Params
    // Return Void
    // Request to the server to delete pet entity
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
    
    // func reqHttpUpdatePetPhoto
    // No Params
    // Return Void
    // Upload pet photo that user select to the server
    func reqHttpUpdatePetPhoto() {
        let reqApi = "pet/photo/update";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        
        AF.upload(multipartFormData: {
            (formdata) in
            formdata.append(String(self.pet?.id ?? self.newPetId!).data(using: .utf8)!, withName: "id");
            formdata.append(self.petImageView.image!.pngData()!, withName: "file", fileName: "swift_new_pet_photo.png", mimeType: "image/jpeg");
        }, to: reqUrl, headers: reqHeader).responseDecodable(of: PetPhotoUpdateDto.self) {
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

            self.unlockEditor();
            if (self.isNewPet) {
                self.performSegue(withIdentifier: "FinishCreatePetUnwindSegue", sender: self);
            } else {
                self.performSegue(withIdentifier: "FinishUpdatePetUnwindSegue", sender: self);
            }
        }
    }
    
    // func reqHttpDeletePetPhoto
    // No Params
    // Return Void
    // Delete pet photo from the server
    func reqHttpDeletePetPhoto() {
        let reqApi = "pet/photo/delete";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["id"] = String(self.pet!.id);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PetPhotoDeleteDto.self) {
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
        }
        
        if (self.isNewPet) {
            self.performSegue(withIdentifier: "FinishCreatePetUnwindSegue", sender: self);
        } else {
            self.performSegue(withIdentifier: "FinishUpdatePetUnwindSegue", sender: self);
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

// Extension - Petphoto image selector
extension UIMyPetEditorVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true);
        let itemProvider = results.first?.itemProvider;
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) {
                (image, error) in
                DispatchQueue.main.async {
                    self.petImageView.image = image as? UIImage;
                    self.deletePetImage = false;
                    self.uploadPetImage = true;
                }
            }
        } else {
            // If user select nothing or load photo from gallery operation failure
            self.petImageView.image = UIImage(named: "ICBaselinePets60WithPadding")!;
            if (self.pet!.photoUrl != nil) {
                self.uploadPetImage = false;
                self.deletePetImage = true;
            }
        }
    }
}
