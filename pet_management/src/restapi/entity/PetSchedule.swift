//
//  Schedule.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/24.
//

import Foundation;

struct PetSchedule: Decodable, Encodable {
    var id: Int;
    var username: String;
    var petList: [Pet];
    var time: String;
    var memo: String;
    var enabled: Bool;
    var petIdList: String;
}

class PetScheduleUtil {
    static func evaluateScheduleAmPm(timeString: String) -> String {
        let timeDate = self.convertTimeToDate(timeString: timeString);
        return timeDate < self.convertTimeToDate(timeString: "12:00:00") ? "오전" : "오후";
    }
    
    static func convertTimeToString(timeDate: Date) -> String {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "HH:mm:ss";
        return dateFormatter.string(from: timeDate);
    }
    
    static func convertTimeToStringWithoutSecond(timeDate: Date) -> String {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "HH:mm";
        return dateFormatter.string(from: timeDate);
    }
    
    static func convertTimeToDate(timeString: String) -> Date {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "HH:mm:ss";
        return dateFormatter.date(from: timeString)!;
    }
    
    static func convertPetName(petList: [Pet]) -> String {
        var petNameString = "";
        petList.forEach() {
            (pet) in
            if (petNameString.count == 0) {
                petNameString = pet.name;
            } else {
                petNameString += ", \(pet.name)";
            }
        }
        return petNameString;
    }
}
