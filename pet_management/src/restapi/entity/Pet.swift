//
//  Pet.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/21.
//

import UIKit;
import Alamofire;

struct Pet: Decodable, Encodable {
    let id: Int;
    var ownername: String;
    var name: String;
    var species: String;
    var breed: String;
    var birth: String;
    var yearOnly: Bool;
    var gender: Bool;
    var message: String?;
    var photoUrl: String?;
}

class PetUtil {
    static func convertAge(birth: String) -> String {
        // extrude year from datestring
        let birthYear = Int(birth.prefix(4));
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "yyyy";
        let currentYear = Int(dateFormatter.string(from: Date()));
        let age = currentYear! - birthYear!;
        return String(age);
    }
    
    static func convertBirthToString(birth: Date) -> String {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd";
        return dateFormatter.string(from: birth);
    }
    
    static func convertBirthToDate(birth: String) -> Date {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd";
        return dateFormatter.date(from: birth)!;
    }
    
    static func convertGender(gender: Bool) -> String {
        return gender ? "♀" : "♂";
    }
    
    // static func reqHttpFetchPetPhoto
    // petId: Int - Pet entity id
    // Return Void
    // Download pet photo
    static func reqHttpFetchPetPhoto(petId: Int, sender: UIViewController, handler: @escaping (_ petPhoto: UIImage) -> Void) {
        let reqApi = "pet/photo/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["id"] = String(petId);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseData() {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            handler(UIImage(data: res.data!) ?? UIImage(named: "ICBaselinePets60WithPadding")!);
        }
    }
}
