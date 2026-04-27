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
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.primary)
                .cornerRadius(14)
        }
    }
}
