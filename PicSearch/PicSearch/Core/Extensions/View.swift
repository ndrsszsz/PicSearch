//
//  View.swift
//  PicSearch
//
//  Created by Andras Szasz on 2025. 09. 29..
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
