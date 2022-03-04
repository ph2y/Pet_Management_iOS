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
    var geoTagLat: Float;
    var geoTagLong: Float;
    var imageAttachments: String?;
    var videoAttachments: String?;
    var fileAttachments: String?;
}

class PostUtil {
    // func repHttpFetchPetPosts
    // No Params
    // Return Void
    // Request to the server to get pet posts data
    static func reqHttpFetchPetPosts(petId: Int, pageIdx: Int, sender: UIViewController, resHandler: @escaping (DataResponse<PetPostFetchDto, AFError>) -> Void) {
        let reqApi = "post/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["pageIndex"] = String(pageIdx);
        reqBody["petId"] = String(petId);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PetPostFetchDto.self) {
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
