//
//  Post.swift
//  pet_management
//
//  Created by newcentury99 on 2022/02/14.
//

import UIKit;
import Alamofire;

struct Post: Decodable, Encodable {
    let id: Int;
    var author: Account;
    var pet: Pet;
    var contents: String;
    var timestamp: String;
    var edited: Bool;
    var serializedHashTags: String;
    var disclosure: String;
    var geoTagLat: Double;
    var geoTagLong: Double;
    var imageAttachments: String?;
    var videoAttachments: String?;
    var fileAttachments: String?;
}

class PostUtil {
    // func decodeFileMetadata
    static func decodeAttachmentMetadata(attachmentMetadata: String?) -> [Attachment] {
        let decoder = JSONDecoder();
        guard (attachmentMetadata != nil) else {
            return [];
        }
        if (attachmentMetadata!.data(using: .utf8) != nil) {
            return try! decoder.decode([Attachment].self, from: attachmentMetadata!.data(using: .utf8)!);
        }
        return [];
    }
    
    // func reqHttpCreatePost
    // No Params
    // Return post: Post - Post content & data
    // Request to the server to get pet posts data
    static func reqHttpCreatePost(postContent: PostCreateParam, sender: UIViewController, resHandler: @escaping (DataResponse<PostCreateDto, AFError>) -> Void) {
        let reqApi = "post/create";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        
        AF.request(reqUrl, method: .post, parameters: postContent, encoder: JSONParameterEncoder.default, headers: reqHeader).responseDecodable(of: PostCreateDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            
            guard (res.value?._metadata.status == true) else {
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
            resHandler(res);
        }
    }
    
    // func reqHttpFetchPetPosts
    // No Params
    // Return Void
    // Request to the server to get pet posts data
    static func reqHttpFetchPetPosts(petId: Int, pageIdx: Int, sender: UIViewController, resHandler: @escaping (DataResponse<PostFetchDto, AFError>) -> Void) {
        let reqApi = "post/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["pageIndex"] = String(pageIdx);
        reqBody["petId"] = String(petId);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PostFetchDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            
            guard (res.value?._metadata.status == true) else {
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
            resHandler(res);
        }
    }
    
    // func reqHttpFetchPosts
    // No Params
    // Return Void
    // Request to the server to get post feed data
    static func reqHttpFetchPosts(pageIdx: Int, currentPostion: Position? = nil, topPostId: Int? = nil, sender: UIViewController, resHandler: @escaping (DataResponse<PostFetchDto, AFError>) -> Void) {
        let reqApi = "post/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        
        if (currentPostion != nil) {
            reqBody["currentLat"] = String(currentPostion!.latitude);
            reqBody["currentLong"] = String(currentPostion!.longitude);
        }
        if (pageIdx != 0){
            reqBody["pageIndex"] = String(pageIdx);
            if (topPostId != nil) {
                reqBody["topPostId"] = String(topPostId!);
            }
        }
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PostFetchDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            
            guard (res.value?._metadata.status == true) else {
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
            resHandler(res);
        }
    }
    
    // func reqHttpUpdatePost
    static func reqHttpUpdatePost(postContent: PostUpdateParam, sender: UIViewController, resHandler: @escaping (DataResponse<PostUpdateDto, AFError>) -> Void) {
        let reqApi = "post/update";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        
        AF.request(reqUrl, method: .post, parameters: postContent, encoder: JSONParameterEncoder.default, headers: reqHeader).responseDecodable(of: PostUpdateDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            
            guard (res.value?._metadata.status == true) else {
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
            resHandler(res);
        }
    }
    
    // func reqHttpDeletePost
    static func reqHttpDeletePost(postId: Int, sender: UIViewController, resHandler: @escaping (DataResponse<PostDeleteDto, AFError>) -> Void) {
        let reqApi = "post/delete";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        let reqBody = [
            "id": String(postId)
        ];
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PostDeleteDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            
            guard (res.value?._metadata.status == true) else {
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
            resHandler(res);
        }
    }
    
    // func reqHttpReportPost
    static func reqHttpReportPost(postId: Int, sender: UIViewController, resHandler: @escaping (DataResponse<PostReportDto, AFError>) -> Void) {
        let reqApi = "post/report";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        let reqBody = [
            "id": String(postId)
        ];
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PostReportDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            
            guard (res.value?._metadata.status == true) else {
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
            resHandler(res);
        }
    }
    
    // func reqHttpFetchPostPhoto
    static func reqHttpFetchPostPhoto(postId: Int, index: Int, sender: UIViewController, resHandler: @escaping (DataResponse<Data, AFError>) -> Void) {
        let reqApi = "post/image/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["id"] = String(postId);
        reqBody["index"] = String(index);
        reqBody["imageType"] = "2";
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseData() {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            guard (res.data != nil) else {
                return;
            }
            resHandler(res);
        }
    }
    
    // func reqHttpFetchPostFile
    static func reqHttpFetchPostFile(postId: Int, index: Int, sender: UIViewController, resHandler: @escaping (DataResponse<Data, AFError>) -> Void) {
        let reqApi = "post/file/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        let reqBody = [
            "id": String(postId),
            "index": String(index)
        ]
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseData() {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            
            resHandler(res);
        }
    }
    
    // func reqHttpUpdatePostFile
    static func reqHttpUpdatePostFile(postId: Int, fileType: String, fileList: [Data], fileNameList: [String] = [], sender: UIViewController, resHandler: @escaping (DataResponse<PostUpdateFileDto, AFError>) -> Void) {
        let reqApi = "post/file/update";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        
        AF.upload(multipartFormData: {
            (formdata) in
            formdata.append(String(postId).data(using: .utf8)!, withName: "id");
            formdata.append(fileType.data(using: .utf8)!, withName: "fileType");
            for (index, file) in fileList.enumerated() {
                if (fileType == "IMAGE_FILE") {
                    formdata.append(file, withName: "fileList[\(index)]", fileName: "swift_new_post\(postId)_photo_\(index).jpg");
                }
                if (fileType == "VIDEO_FILE") {
                    formdata.append(file, withName: "fileList[\(index)]", fileName: "swift_new_post\(postId)_video_\(index).mp4");
                }
                if (fileType == "GENERAL_FILE") {
                    guard (!fileNameList.isEmpty && fileNameList.count == fileList.count) else {
                        return;
                    }
                    formdata.append(file, withName: "fileList[\(index)]", fileName: fileNameList[index]);
                }
            }
        }, to: reqUrl, headers: reqHeader).responseDecodable(of: PostUpdateFileDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }

            guard (res.value?._metadata.status == true) else {
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
            
            resHandler(res);
        }
    }
    
    // func reqHttpDeletePostFile
    static func reqHttpDeletePostFile(postId: Int, fileType: String, sender: UIViewController, resHandler: @escaping (DataResponse<PostDeleteFileDto, AFError>) -> Void) {
        let reqApi = "post/file/delete";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        let reqBody: Dictionary<String, String> = [
            "id": String(postId),
            "fileType": fileType
        ];
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PostDeleteFileDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            guard (res.value?._metadata.status == true) else {
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
            resHandler(res);
        }
    }
    
    // func reqHttpFetchLike
    // No Params
    // Return Void
    // Request to the server to get post like data
    static func reqHttpFetchLike(postId: Int, sender: UIViewController, resHandler: @escaping (DataResponse<LikeFetchDto, AFError>) -> Void) {
        let reqApi = "like/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["postId"] = String(postId);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: LikeFetchDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            guard (res.value?._metadata.status == true) else {
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
            resHandler(res);
        }
    }
    
    // func reqHttpLike
    // No Params
    // Return Void
    // Request to the server to like post
    static func reqHttpLike(postId: Int, sender: UIViewController, resHandler: @escaping (DataResponse<LikeCreateDto, AFError>) -> Void) {
        let reqApi = "like/create";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["postId"] = String(postId);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: LikeCreateDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            
            guard (res.value?._metadata.status == true) else {
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
            resHandler(res);
        }
    }
    
    // func reqHttpUnLike
    // No Params
    // Return Void
    // Request to the server to unlike post
    static func reqHttpUnLike(postId: Int, sender: UIViewController, resHandler: @escaping (DataResponse<LikeDeleteDto, AFError>) -> Void) {
        let reqApi = "like/delete";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["postId"] = String(postId);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: LikeDeleteDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            
            guard (res.value?._metadata.status == true) else {
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
            
            resHandler(res);
        }
    }
}
