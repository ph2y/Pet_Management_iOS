//
//  UIPostEditorVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/10.
//

import UIKit;
import AVKit;
import BSImagePicker;
import Photos;

protocol UIPostEditorDelegate {
    func removeAttachedPhotoAsset(sender: UIPostEditorThumbnailVC);
    func removeAttachedFileAsset(sender: UIPostEditorFileVC);
}

class UIPostEditorVC: UIViewController, UIPostEditorDelegate {
    @IBOutlet weak var petAttachButton: UIButton!;
    @IBOutlet weak var attachedPetLabel: UILabel!;
    @IBOutlet weak var postContentTextView: UITextView!;
    @IBOutlet weak var postTagTextField: UITextField!;
    @IBOutlet weak var postDisclosureSegmentedControl: UISegmentedControl!;
    @IBOutlet weak var postGeoTagSwitch: UISwitch!;
    @IBOutlet weak var postAttachPhotoButton: UIButton!;
    @IBOutlet weak var postAttachVideoButton: UIButton!;
    @IBOutlet weak var postAttachFileButton: UIButton!;
    @IBOutlet weak var attachedImageScrollView: UIScrollView!;
    @IBOutlet weak var attachedFileScrollView: UIScrollView!;
    
    let photoPicker = ImagePickerController();
    let videoPicker = ImagePickerController();
    let filePicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.text, UTType.pdf, UTType.zip], asCopy: true);
    var post: Post?;
    var newPost: PostCreateParam = PostCreateParam();
    var myPetList: [Pet] = [];
    var isNewPost: Bool = true;
    var fromMyPetFeed: Bool = false;
    var uploadAttachPhoto: [UIImage] = [];
    var uploadAttachVideo: [PHAsset] = [];
    var uploadAttachFile: [URL] = [];
    var currentAttachedPhoto: [UIImage] = [];
    var currentAttachedVideo: [URL] = [];
    var currentAttachedFile: [URL] = [];
    
    override func viewDidLoad() {
        // Setup image picker
        self.setupPhotoPicker();
        self.filePicker.delegate = self;
        self.filePicker.allowsMultipleSelection = true;
        
        // Init UI elements
        self.loadMyPetList();
        self.initPostContentTextView();
        
        // Remove dummy child view at scrollview
        self.attachedImageScrollView.subviews[0].removeFromSuperview();
        self.attachedFileScrollView.subviews[0].removeFromSuperview();
        
        // Load current post
        if (self.post != nil) {
            self.loadCurrentPostContent();
        }
    }
    
    func setupPhotoPicker() {
        self.photoPicker.settings.selection.min = 1;
        self.photoPicker.settings.selection.max = 10;
        self.photoPicker.settings.fetch.assets.supportedMediaTypes = [.image];
    }
    
    func setupVideoPicker() {
        self.videoPicker.settings.selection.min = 1;
        self.videoPicker.settings.selection.max = 10;
        self.videoPicker.settings.fetch.assets.supportedMediaTypes = [.video];
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
    
    func loadAttachedPhotoAssets(assetList: [PHAsset]) {
        guard (assetList.count != 0) else {
            return;
        }
        self.uploadAttachPhoto = assetList.map({
            (asset) in
            return AttachmentUtil.getImageFromPHAsset(asset: asset, size: CGSize(width: 1000, height: 1000));
        });
        for asset in assetList {
            // Privent duplication
            let duplicatedThumbnail = self.children.first() {
                (vc) in
                if (type(of: vc) == UIPostEditorThumbnailVC.self) {
                    let thumbnailVC = vc as! UIPostEditorThumbnailVC;
                    return thumbnailVC.asset != nil && thumbnailVC.asset == asset;
                }
                return false;
            }
            if (duplicatedThumbnail != nil) {
                duplicatedThumbnail!.removeFromParent();
                duplicatedThumbnail!.view.removeFromSuperview();
            }
            
            // Create image preview
            let thumbnailVC = storyboard!.instantiateViewController(withIdentifier: "PostEditorThumbnailVC") as! UIPostEditorThumbnailVC;
            let assetIdx = self.uploadAttachPhoto.firstIndex() {
                (photo) in
                return photo.pngData() == AttachmentUtil.getImageFromPHAsset(asset: asset, size: CGSize(width: 1000, height: 1000)).pngData();
            }
            thumbnailVC.delegate = self;
            thumbnailVC.asset = asset;
            thumbnailVC.thumbnail = AttachmentUtil.getImageFromPHAsset(asset: asset);
            thumbnailVC.view.frame = CGRect(x: 80 * CGFloat(self.currentAttachedPhoto.count + assetIdx!), y: 0, width: 75, height: 75);
            self.addChild(thumbnailVC);
            self.attachedImageScrollView.addSubview(thumbnailVC.view);
        }
        self.resizeAttachedImageScrollViewWidth();
        self.postAttachPhotoButton.setTitle("(\(self.currentAttachedPhoto.count + self.uploadAttachPhoto.count)/10)", for: .normal);
    }
    
    func removeAttachedPhotoAsset(sender: UIPostEditorThumbnailVC) {
        // If the photo is newly uploaded
        if (sender.asset != nil) {
            let assetIdx = self.uploadAttachPhoto.firstIndex() {
                (photo) in
                return photo.pngData() == AttachmentUtil.getImageFromPHAsset(asset: sender.asset!, size: CGSize(width: 1000, height: 1000)).pngData();
            }
            self.uploadAttachPhoto.remove(at: assetIdx!);
            self.photoPicker.deselect(asset: sender.asset!);
        }
        sender.view.removeFromSuperview();
        sender.removeFromParent();
        
        // Pull left thumbnail views to fill removed thumbnail position
        for thumbnailVC in self.children.filter({
            (vc) in
            return type(of: vc) == UIPostEditorThumbnailVC.self;
        }) {
            let thumbnailVC = thumbnailVC as! UIPostEditorThumbnailVC;
            
            if (thumbnailVC.asset != nil) {
                let assetIdx = self.uploadAttachPhoto.firstIndex() {
                    (photo) in
                    return photo.pngData() == AttachmentUtil.getImageFromPHAsset(asset: thumbnailVC.asset!, size: CGSize(width: 1000, height: 1000)).pngData();
                }
                thumbnailVC.view.frame = CGRect(x: 80 * CGFloat(self.currentAttachedPhoto.count + assetIdx!), y: 0, width: 75, height: 75);
            } else {
                let assetIdx = self.currentAttachedPhoto.firstIndex(of: thumbnailVC.thumbnail!);
                thumbnailVC.view.frame = CGRect(x: 80 * CGFloat(assetIdx!), y: 0, width: 75, height: 75);
            }
        }
        
        self.resizeAttachedImageScrollViewWidth();
        self.postAttachPhotoButton.setTitle("(\(self.currentAttachedPhoto.count + self.uploadAttachPhoto.count)/10)", for: .normal);
    }
    
    func resizeAttachedImageScrollViewWidth() {
        let previewWidth = CGFloat((self.uploadAttachPhoto.count + self.uploadAttachVideo.count) * 80);
        if (previewWidth < self.view.frame.width) {
            self.attachedImageScrollView.contentSize.width = self.attachedImageScrollView.frame.width;
        } else {
            self.attachedImageScrollView.contentSize.width = previewWidth;
        }
    }
    
    func loadAttachedFileAssets(fileUrl: URL) {
        guard(!self.uploadAttachFile.contains(fileUrl)) else {
            return;
        }
        self.uploadAttachFile.append(fileUrl);
        
        // Create attachment file record
        let recordVC = storyboard!.instantiateViewController(withIdentifier: "PostEditorFileVC") as! UIPostEditorFileVC;
        recordVC.delegate = self;
        recordVC.fileUrl = fileUrl;
        recordVC.view.frame = CGRect(x: 5, y: 30 * CGFloat(self.uploadAttachFile.count - 1), width: (self.attachedFileScrollView.frame.width - 10), height: 30);
        self.addChild(recordVC);
        self.attachedFileScrollView.addSubview(recordVC.view);
        self.resizeAttachedFileScrollViewHeight();
        self.postAttachFileButton.setTitle("(\(self.uploadAttachFile.count)/10)", for: .normal);
    }
    
    func removeAttachedFileAsset(sender: UIPostEditorFileVC) {
        self.uploadAttachFile.remove(at: self.uploadAttachFile.firstIndex(of: sender.fileUrl!)!);
        sender.view.removeFromSuperview();
        sender.removeFromParent();
        
        // Pull up record views to fill removed record position
        for (index, recordVC) in self.children.filter({
            (vc) in
            return type(of: vc) == UIPostEditorFileVC.self;
        }).enumerated() {
            let recordVC = recordVC as! UIPostEditorFileVC;
            recordVC.view.frame = CGRect(x: 5, y: 30 * CGFloat(index), width: (self.attachedFileScrollView.frame.width - 10), height: 30);
        }
        self.resizeAttachedFileScrollViewHeight();
        self.postAttachFileButton.setTitle("(\(self.uploadAttachFile.count)/10)", for: .normal);
    }
    
    func resizeAttachedFileScrollViewHeight() {
        let recordHeight = CGFloat(self.uploadAttachFile.count * 30);
        if (recordHeight < 75) {
            self.attachedFileScrollView.contentSize.height = 75;
        } else {
            self.attachedFileScrollView.contentSize.height = recordHeight;
        }
    }
    
    func uploadPhotoList(postId: Int, syncronizer: DispatchGroup) {
        syncronizer.enter();
        PostUtil.reqHttpUpdatePostFile(postId: postId, fileType: "IMAGE_FILE", fileList: self.uploadAttachPhoto.map({
            (photo) in
            return photo.jpegData(compressionQuality: 0.7)!;
        }), sender: self) {
            (res) in
            syncronizer.leave();
        }
    }
    
    func uploadVideoList(postId: Int, syncronizer: DispatchGroup) {
        let videoConvertSyncSemaphore = DispatchSemaphore(value: 0);
        let videoManager = PHImageManager();
        let option = PHVideoRequestOptions();
        option.version = .original;
        var uploadVideoDataList: [Data] = [];
        
        for asset in self.uploadAttachVideo {
            videoManager.requestAVAsset(forVideo: asset, options: option) {
                (asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) in
                let videoUrl = asset as? AVURLAsset;
                guard (videoUrl != nil) else {
                    return;
                }
                guard let videoData = try? Data(contentsOf: videoUrl!.url) else {
                    return;
                }
                uploadVideoDataList.append(videoData);
                videoConvertSyncSemaphore.signal();
            }
            videoConvertSyncSemaphore.wait();
        }
        
        syncronizer.enter();
        PostUtil.reqHttpUpdatePostFile(postId: postId, fileType: "VIDEO_FILE", fileList: uploadVideoDataList, sender: self) {
            (res) in
            syncronizer.leave();
        }
    }
    
    func uploadFileList(postId: Int, syncronizer: DispatchGroup) {
        var uploadFileDataList: [Data] = [];
        var uploadFileNameList: [String] = [];
        for url in self.uploadAttachFile {
            guard let fileData = try? Data(contentsOf: url) else {
                return;
            }
            uploadFileDataList.append(fileData);
            uploadFileNameList.append(url.lastPathComponent);
        }
        
        syncronizer.enter();
        PostUtil.reqHttpUpdatePostFile(postId: postId, fileType: "GENERAL_FILE", fileList: uploadFileDataList, fileNameList: uploadFileNameList, sender: self) {
            (res) in
            syncronizer.leave();
        }
    }
    
    func lockEditor() {
        let alert = UIAlertController(title: nil, message: "게시물 데이터 및 첨부파일을 업로드 하는 중입니다", preferredStyle: .alert);
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50));
        loadingIndicator.hidesWhenStopped = true;
        loadingIndicator.style = UIActivityIndicatorView.Style.medium;
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator);
        present(alert, animated: true, completion: nil);
    }

    
    // Action Methods
    @IBAction func attachPhotoButtonOnclick(_ sender: UIButton) {
        self.presentImagePicker(self.photoPicker, select: nil, deselect: {
            (asset) in
            let thumbnailVCList = self.children.filter({
                (vc) in
                return type(of: vc) == UIPostEditorThumbnailVC.self;
            });
            let thumbnailVC = thumbnailVCList.first() {
                (vc) in
                let thumbnailVC = vc as! UIPostEditorThumbnailVC;
                return thumbnailVC.thumbnail!.pngData() == AttachmentUtil.getImageFromPHAsset(asset: asset).pngData();
            }
            if (thumbnailVC != nil) {
                self.removeAttachedPhotoAsset(sender: thumbnailVC as! UIPostEditorThumbnailVC);
            }
        }, cancel: nil, finish: {
                (assetList) in
            self.loadAttachedPhotoAssets(assetList: assetList);
        });
    }
    
    @IBAction func attachVideoButtonOnClick(_ sender: UIButton) {
        
    }
    
    @IBAction func attachFileButtonOnClick(_ sender: UIButton) {
        self.present(self.filePicker, animated: true, completion: nil);
    }
    
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
            let attachmentSyncronizer = DispatchGroup();
            
            self.lockEditor();
            if (!self.uploadAttachPhoto.isEmpty) {
                self.uploadPhotoList(postId: res.value!.id, syncronizer: attachmentSyncronizer);
            }
            if (!self.uploadAttachVideo.isEmpty) {
                self.uploadVideoList(postId: res.value!.id, syncronizer: attachmentSyncronizer);
            }
            if (!self.uploadAttachFile.isEmpty) {
                self.uploadFileList(postId: res.value!.id, syncronizer: attachmentSyncronizer);
            }
            
            attachmentSyncronizer.notify(queue: .main) {
                self.dismiss(animated: false) {
                    if (self.fromMyPetFeed) {
                        self.performSegue(withIdentifier: "publishPostFromMyPetSegue", sender: self);
                    } else {
                        self.performSegue(withIdentifier: "publishPostFromFeedSegue", sender: self);
                    }
                }
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

// Extension - UIDocumentPickerDelegate delegate
extension UIPostEditorVC: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // TODO: 장래 애플 API 업데이트시 한꺼번에 다중 선택이 가능하도록 개선
        // API 문제로 multipleSelect 옵션이 작동하지 않아 1개씩 추가만 가능 (파일 1개를 선택하면 창이 닫힘)
        self.loadAttachedFileAssets(fileUrl: urls[0]);
    }
}
