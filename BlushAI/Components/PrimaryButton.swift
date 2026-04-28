//
//  PrimaryButton.swift
//  Blush
//
//  Created by Bhoomi on 27/04/26.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Sniglet-ExtraBold", size: 17))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.primary)
                .cornerRadius(14)
        }
    }
}
