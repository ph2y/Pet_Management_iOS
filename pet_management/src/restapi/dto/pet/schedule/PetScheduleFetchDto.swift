//
//  PetScheduleFetchDto.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/25.
//

struct PetScheduleFetchDto: Decodable {
    let _metadata: HttpMetaData;
    var petScheduleList: [PetSchedule]?;
}
