//
//  PredectionModel.swift
//  DrHouseIosAppLast
//
//  Created by Mac2021 on 2/12/2024.
//

import Foundation
struct PredictionResponse: Codable {
    let description: String
    let medications: [String]
    let precautions: String
    let predicted_disease: String
    let recommended_diet: [String]
    let workout: [String]
    
    enum CodingKeys: String, CodingKey {
        case description
        case medications
        case precautions
        case predicted_disease
        case recommended_diet
        case workout
    }
}
