//
//  CommentCreateDto.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/16.
//

struct CommentCreateDto: Decodable {
    let _metadata: HttpMetaData;
    var id: Int?;
}
