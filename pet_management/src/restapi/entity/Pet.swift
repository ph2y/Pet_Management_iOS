//
//  Pet.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/21.
//

import UIKit;

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
    
    static func convertImage(photoUrl: String?) -> UIImage {
        if (photoUrl == nil) {
            return UIImage(named: "ICBaselinePets60WithPadding")!;
        } else {
            var imgData: Data;
            do {
                imgData = try Data(contentsOf: URL(string: photoUrl!)!);
            } catch {
                return UIImage(named: "ICBaselinePets60WithPadding")!;
            }
            return UIImage(data: imgData)!;
        }
    }
}
