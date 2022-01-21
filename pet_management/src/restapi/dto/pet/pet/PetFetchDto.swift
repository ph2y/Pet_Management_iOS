//
//  PetFetchDto.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/21.
//

struct PetFetchDto: Decodable {
    let _metadata: HttpMetaData;
    let petList: [Pet]?;
}
