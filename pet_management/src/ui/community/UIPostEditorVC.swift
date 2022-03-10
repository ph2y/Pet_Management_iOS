//
//  UIPostEditorVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/10.
//

import UIKit;

class UIPostEditorVC: UIViewController {
    @IBOutlet weak var petAttachButton: UIButton!;
    @IBOutlet weak var attachedPetLabel: UILabel!;
    @IBOutlet weak var postContentTextView: UITextView!;
    @IBOutlet weak var postTagTextField: UITextField!;
    @IBOutlet weak var postDisclosureSegmentedControl: UISegmentedControl!;
    @IBOutlet weak var postGeoTagSwitch: UISwitch!;
    @IBOutlet weak var postAttachPhotoButton: UIButton!;
    @IBOutlet weak var postAttachVideoButton: UIButton!;
    @IBOutlet weak var postAttachFileButton: UIButton!;
    @IBOutlet weak var attachedImageStackView: UIStackView!;
    @IBOutlet weak var attachedFileStackView: UIStackView!;
    
    var post: Post?;
    var newPost: PostCreateParam = PostCreateParam();
    var myPetList: [Pet] = [];
    var isNewPost: Bool = true;
    var fromMyPetFeed: Bool = false;
    var uploadAttachPhoto: Bool = false;
    var uploadAttachVideo: Bool = false;
    var uploadAttachFile: Bool = false;
    
    
    override func viewDidLoad() {
        // Setup image picker
        
        // Init UI elements
        self.loadMyPetList();
        self.initPostContentTextView();
        
        // Load current post
        if (self.post != nil) {
            self.loadCurrentPostContent();
        }
    }
    
    func loadMyPetList() {
        // load data
        if (UserDefaults.standard.object(forKey: "myPetList") != nil) {
            let data = UserDefaults.standard.value(forKey: "myPetList") as! Data;
            self.myPetList = try! PropertyListDecoder().decode([Pet].self, from: data);
        } else {
            self.present(UIUtil.makeSimplePopup(title: "로컬 저장소 에러", message: "로컬 저장소에서 펫 정보를 로드하지 못했습니다", onClose: nil), animated: true);
            return;
        }
        
        // Create pet menu objects
        var attachPetMenu: [UIAction] = [];
        for pet in self.myPetList {
            attachPetMenu.append(UIAction(title: pet.name) {
                _ in
                self.newPost.petId = pet.id;
                self.attachedPetLabel.text = "태그된 반려동물: \(pet.name)";
            });
        }
        
        // Add pet selection menu to the button
        self.petAttachButton.menu = UIMenu(title: "", children: attachPetMenu);
    }
    
    func loadCurrentPostContent() {
        let disclosureIdx: Dictionary<String, Int> = [
            "PUBLIC": 0,
            "FRIEND": 1,
            "PRIVATE": 2
        ];
        
        self.attachedPetLabel.text = "태그된 반려동물: \(self.post!.pet.name)";
        self.postContentTextView.text = self.post!.contents;
        self.postTagTextField.text = self.post!.serializedHashTags;
        self.postDisclosureSegmentedControl.selectedSegmentIndex = disclosureIdx[self.post!.disclosure] ?? disclosureIdx["PUBLIC"]!;
        self.postGeoTagSwitch.isOn = !(self.post!.geoTagLat == 0 && self.post!.geoTagLong == 0);
    }
    
    func validatePostContent() -> Bool {
        if (self.newPost.petId == nil) {
            self.present(UIUtil.makeSimplePopup(title: "게시물 작성 에러", message: "반려동물이 태그되지 않았습니다", onClose: nil), animated: true);
            return false;
        }
        if (self.newPost.contents.isEmpty ||
            self.postContentTextView.textColor == UIColor.lightGray) {
            self.present(UIUtil.makeSimplePopup(title: "게시물 작성 에러", message: "글 내용이 입력되지 않았습니다", onClose: nil), animated: true);
            return false;
        }
        if (self.newPost.disclosure != "PUBLIC" && self.newPost.disclosure != "FRIEND" && self.newPost.disclosure != "PRIVATE") {
            self.present(UIUtil.makeSimplePopup(title: "게시물 작성 에러", message: "게시물 공개범위가 선택되지 않았습니다", onClose: nil), animated: true);
            return false;
        }
        return true;
    }
    
    // Action Methods
    @IBAction func publishButtonOnClick(_ sender: UIButton) {
        let disclosureString: Dictionary<Int, String> = [
            0: "PUBLIC",
            1: "FRIEND",
            2: "PRIVATE"
        ];
        self.newPost.contents = self.postContentTextView.text;
        self.newPost.hashTags = self.postTagTextField.text!.components(separatedBy: ",");
        self.newPost.disclosure = disclosureString[self.postDisclosureSegmentedControl.selectedSegmentIndex] ?? "PUBLIC";
        
        guard(self.validatePostContent()) else {
            return;
        }
        
        PostUtil.reqHttpCreatePost(postContent: self.newPost, sender: self) {
            (res) in
            if (self.fromMyPetFeed) {
                self.performSegue(withIdentifier: "publishPostFromMyPetSegue", sender: self);
            } else {
                self.performSegue(withIdentifier: "publishPostFromFeedSegue", sender: self);
            }
        }
    }
}

// Extension - PostContentTextView delegate
extension UIPostEditorVC: UITextViewDelegate {
    func initPostContentTextView() {
        self.postContentTextView.delegate = self;
        self.postContentTextView.text = "게시글 내용을 입력하세요";
        self.postContentTextView.textColor = UIColor.lightGray;
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (self.postContentTextView.textColor == UIColor.lightGray) {
            self.postContentTextView.text = nil;
            self.postContentTextView.textColor = UIColor.black;
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (self.postContentTextView.text.isEmpty) {
            self.postContentTextView.text = "게시글 내용을 입력하세요";
            self.postContentTextView.textColor = UIColor.lightGray;
        }
    }
}
