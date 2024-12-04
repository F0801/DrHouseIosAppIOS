//
//  EditProfileViewModel.swift
//  DrHouseIosAppLast
//
//  Created by Mac2021 on 4/12/2024.
//
import Foundation
import Combine
import SwiftUI

class EditProfileViewModel:ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
}
