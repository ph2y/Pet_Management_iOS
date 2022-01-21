//
//  Pet.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/21.
//

struct Pet: Decodable {
    let id: Int;
    let ownername: String;
    let name: String;
    let species: String;
    let breed: String;
    let birth: String;
    let yearOnly: Bool;
    let gender: Bool;
    let message: String?;
    let photoUrl: String?;
}
