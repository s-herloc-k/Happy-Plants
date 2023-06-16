//
//  UserSettings.swift
//  Plants
//
//  Created by Гога  on 10.05.2023.
//

import SwiftUI

class UserSettings: ObservableObject {
    @Published var score = 0
}

struct UserSettings_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
