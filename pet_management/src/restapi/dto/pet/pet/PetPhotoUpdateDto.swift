//
//  PetPhotoUpdateDto.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/23.
//

struct PetPhotoUpdateDto: Decodable {
    let _metadata: HttpMetaData;
    let fileUrl: String?;
}
