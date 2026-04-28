//
//  StatCard.swift
//  Blush
//
//  Created by Bhoomi on 27/04/26.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.custom("Sniglet-Regular", size: 12)).foregroundColor(.secondary)
            Text(value).font(.custom("Sniglet-ExtraBold", size: 20))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}
