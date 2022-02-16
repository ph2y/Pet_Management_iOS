//
//  PetPostFetchDto.swift
//  pet_management
//
//  Created by newcentury99 on 2022/02/14.
//

import Foundation

struct PetPostFetchDto: Decodable {
    let _metadata: HttpMetaData;
    var postList: [Post]?;
    let isLast: Bool;
}
