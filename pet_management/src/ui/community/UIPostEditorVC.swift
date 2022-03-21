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
    var isNewPost: Bool = true;
    var fromMyPetFeed: Bool = false;
    var myPetList: [Pet] = [];
    // new post contents
    var newPost: PostCreateParam = PostCreateParam();
    var uploadAttachPhoto: [UIImage] = [];
    var uploadAttachVideo: [PHAsset] = [];
    var uploadAttachFile: [URL] = [];
    // current post contents (for edit only)
    var currentPost: Post?;
    // post content index which will be deleted
    var deleteAttachedPhoto: Bool = false;
    var deleteAttachedVideo: Bool = false;
    var deleteAttachedFile: Bool = false;
    
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
        if (!self.isNewPost && self.currentPost != nil) {
            self.loadCurrentPostContent();
            self.loadPreviousPhotoAssets();
            self.loadPreviousFileAssets();
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
    
    func loadCurrentPostContent() {
        let disclosureIdx: Dictionary<String, Int> = [
            "PUBLIC": 0,
            "FRIEND": 1,
            "PRIVATE": 2
        ];
        
        self.attachedPetLabel.text = "태그된 반려동물: \(self.currentPost!.pet.name)";
        self.newPost.petId = self.currentPost!.pet.id;
        self.postContentTextView.text = self.currentPost!.contents;
        self.postContentTextView.textColor = UIColor.black;
        self.postTagTextField.text = self.currentPost!.serializedHashTags;
        self.postDisclosureSegmentedControl.selectedSegmentIndex = disclosureIdx[self.currentPost!.disclosure] ?? disclosureIdx["PUBLIC"]!;
        self.postGeoTagSwitch.isOn = !(self.currentPost!.geoTagLat == 0 && self.currentPost!.geoTagLong == 0);
        self.postGeoTagSwitch.isEnabled = false;
    }
    
    func loadPreviousPhotoAssets() {
        let loadSyncronizer = DispatchGroup();
        let currentPhotoAssetCnt = PostUtil.decodeAttachmentMetadata(attachmentMetadata: self.currentPost!.imageAttachments).count;
        
        guard(currentPhotoAssetCnt != 0) else {
            return;
        }
        
        // Enable previous photo attachement perge flag
        self.deleteAttachedPhoto = true;
        
        // fetch previous attached photo
        for index in 0..<currentPhotoAssetCnt {
            loadSyncronizer.enter();
            PostUtil.reqHttpFetchPostPhoto(postId: self.currentPost!.id, index: index, sender: self) {
                (res) in
                let photo = UIImage(data: res.data!)!;
                self.uploadAttachPhoto.append(photo);
                // Create image preview
                self.appendAttachedPhotoThumbnail(photo: photo);
                loadSyncronizer.leave();
            }
            
            loadSyncronizer.notify(queue: .main) {
                self.resizeAttachedImageScrollViewWidth();
                self.postAttachPhotoButton.setTitle("(\(self.uploadAttachPhoto.count)/10)", for: .normal);
            }
        }
    }
    
    func loadPreviousFileAssets() {
        let loadSyncronizer = DispatchGroup();
        let currentFileAssetCnt = PostUtil.decodeAttachmentMetadata(attachmentMetadata: self.currentPost!.fileAttachments).count;
        
        guard(currentFileAssetCnt != 0) else {
            return;
        }
        
        // Enable previous general attachment perge flag
        self.deleteAttachedFile = true;
        
        //fetch previous attached file
        for index in 0..<currentFileAssetCnt {
            loadSyncronizer.enter();
            PostUtil.reqHttpFetchPostFile(postId: self.currentPost!.id, index: index, sender: self) {
                (res) in
                let directory = NSTemporaryDirectory();
                let fileName = NSUUID().uuidString;

                // This returns a URL? even though it is an NSURL class method
                let fileUrl = NSURL.fileURL(withPathComponents: [directory, fileName]);
                if (fileUrl != nil) {
                    self.uploadAttachFile.append(fileUrl!);
                    self.appendAttachedFileLabel(fileUrl: fileUrl!);
                }
            }
        }
        
        loadSyncronizer.notify(queue: .main) {
            self.resizeAttachedFileScrollViewHeight();
            self.postAttachFileButton.setTitle("(\(self.uploadAttachFile.count)/10)", for: .normal);
        }
    }
    
    func loadAttachedPhotoAssets(assetList: [PHAsset]) {
        guard (!assetList.isEmpty) else {
            return;
        }
        let photoList: [UIImage] = assetList.map({
            (asset) in
            return AttachmentUtil.getImageFromPHAsset(asset: asset, size: CGSize(width: 1920, height: 1080));
        });
        for (index, photo) in photoList.enumerated() {
            // Privent duplication
            let duplicatedThumbnail = self.children.first() {
                (vc) in
                if (type(of: vc) == UIPostEditorThumbnailVC.self) {
                    let thumbnailVC = vc as! UIPostEditorThumbnailVC;
                    return thumbnailVC.thumbnail!.pngData() == photo.pngData();
                }
                return false;
            }
            if (duplicatedThumbnail != nil) {
                continue;
            }
            
            self.uploadAttachPhoto.append(photo);
            
            // Create image preview
            self.appendAttachedPhotoThumbnail(photo: photo, asset: assetList[index]);
            
        }
        self.resizeAttachedImageScrollViewWidth();
        self.postAttachPhotoButton.setTitle("(\(self.uploadAttachPhoto.count)/10)", for: .normal);
    }
    
    func appendAttachedPhotoThumbnail(photo: UIImage, asset: PHAsset? = nil) {
        let thumbnailVC = storyboard!.instantiateViewController(withIdentifier: "PostEditorThumbnailVC") as! UIPostEditorThumbnailVC;
        let assetIdx = self.uploadAttachPhoto.firstIndex() {
            (attachedPhoto) in
            return attachedPhoto.pngData() == photo.pngData();
        }
        thumbnailVC.delegate = self;
        thumbnailVC.asset = asset;
        thumbnailVC.thumbnail = photo;
        thumbnailVC.view.frame = CGRect(x: 80 * CGFloat(assetIdx!), y: 0, width: 75, height: 75);
        self.addChild(thumbnailVC);
        self.attachedImageScrollView.addSubview(thumbnailVC.view);
    }
    
    func removeAttachedPhotoAsset(sender: UIPostEditorThumbnailVC) {
        // If the photo is newly uploaded
        let assetIdx = self.uploadAttachPhoto.firstIndex() {
            (photo) in
            return photo.pngData() == sender.thumbnail!.pngData();
        }
        
        // Deselect from picker
        if (sender.asset != nil) {
            self.photoPicker.deselect(asset: sender.asset!);
        }
        
        // Remove thumbanil VC
        self.uploadAttachPhoto.remove(at: assetIdx!);
        sender.view.removeFromSuperview();
        sender.removeFromParent();
        
        // Pull left thumbnail views to fill removed thumbnail position
        for thumbnailVC in self.children.filter({
            (vc) in
            return type(of: vc) == UIPostEditorThumbnailVC.self;
        }) {
            let thumbnailVC = thumbnailVC as! UIPostEditorThumbnailVC;
            let assetIdx = self.uploadAttachPhoto.firstIndex() {
                (photo) in
                return photo.pngData() == thumbnailVC.thumbnail!.pngData();
            }
            thumbnailVC.view.frame = CGRect(x: 80 * CGFloat(assetIdx!), y: 0, width: 75, height: 75);
        }
        
        self.resizeAttachedImageScrollViewWidth();
        self.postAttachPhotoButton.setTitle("(\(self.uploadAttachPhoto.count)/10)", for: .normal);
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
        self.appendAttachedFileLabel(fileUrl: fileUrl);
        self.resizeAttachedFileScrollViewHeight();
        self.postAttachFileButton.setTitle("(\(self.uploadAttachFile.count)/10)", for: .normal);
    }
    
    func appendAttachedFileLabel(fileUrl: URL) {
        let recordVC = storyboard!.instantiateViewController(withIdentifier: "PostEditorFileVC") as! UIPostEditorFileVC;
        recordVC.delegate = self;
        recordVC.fileUrl = fileUrl;
        recordVC.view.frame = CGRect(x: 5, y: 30 * CGFloat(self.uploadAttachFile.count - 1), width: (self.attachedFileScrollView.frame.width - 10), height: 30);
        self.addChild(recordVC);
        self.attachedFileScrollView.addSubview(recordVC.view);
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
            return photo.jpegData(compressionQuality: 1)!;
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
        let alert = UIAlertController(title: nil, message: "게시글 업로드 중입니다", preferredStyle: .alert);
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50));
        loadingIndicator.hidesWhenStopped = true;
        loadingIndicator.style = UIActivityIndicatorView.Style.medium;
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator);
        present(alert, animated: true, completion: nil);
    }
    
    func processAttachmentUploadQueue(postId: Int) {
        let attachmentSyncronizer = DispatchGroup();
        
        self.lockEditor();
        
        // Process photo attachements
        if (self.deleteAttachedPhoto) {
            attachmentSyncronizer.enter();
            PostUtil.reqHttpDeletePostFile(postId: self.currentPost!.id, fileType: "IMAGE_FILE", sender: self) {
                (res) in
                attachmentSyncronizer.leave();
            }
        }
        if (!self.uploadAttachPhoto.isEmpty) {
            self.uploadPhotoList(postId: postId, syncronizer: attachmentSyncronizer);
        }
        
        // Process video attachements
        if (self.deleteAttachedVideo) {
            attachmentSyncronizer.enter();
            PostUtil.reqHttpDeletePostFile(postId: self.currentPost!.id, fileType: "VIDEO_FILE", sender: self) {
                (res) in
                attachmentSyncronizer.leave();
            }
        }
        if (!self.uploadAttachVideo.isEmpty) {
            self.uploadVideoList(postId: postId, syncronizer: attachmentSyncronizer);
        }
        
        // Process general attachements
        if (self.deleteAttachedFile) {
            attachmentSyncronizer.enter();
            PostUtil.reqHttpDeletePostFile(postId: self.currentPost!.id, fileType: "GENERAL_FILE", sender: self) {
                (res) in
                attachmentSyncronizer.leave();
            }
        }
        if (!self.uploadAttachFile.isEmpty) {
            self.uploadFileList(postId: postId, syncronizer: attachmentSyncronizer);
        }
        
        // Close editor
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
                return thumbnailVC.thumbnail!.pngData() == AttachmentUtil.getImageFromPHAsset(asset: asset, size: CGSize(width: 1920, height: 1080)).pngData();
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
        
        // Set geotag
        if (self.isNewPost) {
            self.newPost.geoTagLat = 0;
            self.newPost.geoTagLong = 0;
        } else {
            self.newPost.geoTagLat = self.currentPost!.geoTagLat;
            self.newPost.geoTagLong = self.currentPost!.geoTagLong;
        }
        
        guard(self.validatePostContent()) else {
            return;
        }
        
        if (self.isNewPost) {
            PostUtil.reqHttpCreatePost(postContent: self.newPost, sender: self) {
                (res) in
                self.processAttachmentUploadQueue(postId: res.value!.id);
            }
        } else {
            let editedPost = PostUpdateParam(id: self.currentPost!.id, petId: self.newPost.petId, contents: self.newPost.contents, hashTags: self.newPost.hashTags, disclosure: self.newPost.disclosure, geoTagLat: self.newPost.geoTagLat, geoTagLong: self.newPost.geoTagLong);
            
            PostUtil.reqHttpUpdatePost(postContent: editedPost, sender: self) {
                (res) in
                self.processAttachmentUploadQueue(postId: self.currentPost!.id);
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
