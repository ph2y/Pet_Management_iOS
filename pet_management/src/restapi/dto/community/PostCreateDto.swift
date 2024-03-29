//
//  PostCreateDto.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/10.
//

struct PostCreateParam: Encodable {
    var petId: Int?;
    var contents: String = "";
    var hashTags: [String] = [];
    var disclosure: String = "PUBLIC";
    var geoTagLat: Double = 0;
    var geoTagLong: Double = 0;
}

struct PostCreateDto: Decodable {
    let _metadata: HttpMetaData;
    var id: Int;
}
