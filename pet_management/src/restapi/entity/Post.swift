//
//  Post.swift
//  pet_management
//
//  Created by newcentury99 on 2022/02/14.
//

import Foundation

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
