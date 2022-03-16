//
//  PostFetchDto.swift
//  pet_management
//
//  Created by newcentury99 on 2022/02/14.
//

import Foundation

struct PostFetchDto: Decodable {
    let _metadata: HttpMetaData;
    var postList: [Post]?;
    let pageable: Pageable;
    let isLast: Bool;
}
