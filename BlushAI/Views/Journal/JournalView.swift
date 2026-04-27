//
//  JournalView.swift
//  Blush
//
//  Created by Bhoomi on 27/04/26.
//

import SwiftUI

struct JournalView: View {
    
    @State private var expected = ""
    @State private var ease = ""
    @State private var productive = ""
    @State private var rest = ""
    @State private var rushed = ""
    @State private var feltGood = ""
    @State private var enjoyed = ""
    @State private var dayType = ""
    
    @State private var coreMemory = ""
    @State private var manifestation = ""
    
    @State private var hasChanges = false
    @State private var isSaved = false
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(alignment: .leading, spacing: 15) {
                
                header
                
                questionBlock(
                    title: "Did today go the way you expected?",
                    selection: $expected,
                    options: [
                        "😊 Yes",
                        "😐 Not really"
                    ]
                )
                
                questionBlock(
                    title: "Did you feel at ease today?",
                    selection: $ease,
                    options: [
                        "🌸 Yes",
                        "🍂 Not really"
                    ]
                )
                
                questionBlock(
                    title: "Did you feel productive today?",
                    selection: $productive,
                    options: [
                        "👍 Yes",
                        "🌿 A little",
                        "👎 Not really"
                    ]
                )
                
                questionBlock(
                    title: "Did you get enough rest?",
                    selection: $rest,
                    options: [
                        "😴 Yes",
                        "🌿 Somewhat",
                        "😵 No"
                    ]
                )
                
                questionBlock(
                    title: "Did you feel rushed today?",
                    selection: $rushed,
                    options: [
                        "🌸 No",
                        "⚡ Yes"
                    ]
                )
                
                questionBlock(
                    title: "Did you feel good at any point today?",
                    selection: $feltGood,
                    options: [
                        "🌞 Yes",
                        "🌙 No"
                    ]
                )
                
                questionBlock(
                    title: "Was there a moment you enjoyed today?",
                    selection: $enjoyed,
                    options: [
                        "🌸 Yes",
                        "🍂 No"
                    ]
                )
                
                questionBlock(
                    title: "What kind of day was today?",
                    selection: $dayType,
                    options: [
                        "✨ Great",
                        "🌷 Good",
                        "🌤 Hoping tomorrow feels softer"
                    ]
                )
                
                textInputBlock(
                    title: "Today's Core Memory",
                    placeholder: "A moment worth keeping...",
                    text: $coreMemory
                )
                
                textInputBlock(
                    title: "Manifestation for Tomorrow",
                    placeholder: "What are you calling in tomorrow?",
                    text: $manifestation
                )
                
                saveButton
            }
            .padding(18)
        }
        .background(
            Color(red: 0.99, green: 0.97, blue: 0.97)
                .ignoresSafeArea()
        )
        .navigationTitle("Journal")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: expected) { _ in markChanged() }
        .onChange(of: ease) { _ in markChanged() }
        .onChange(of: productive) { _ in markChanged() }
        .onChange(of: rest) { _ in markChanged() }
        .onChange(of: rushed) { _ in markChanged() }
        .onChange(of: feltGood) { _ in markChanged() }
        .onChange(of: enjoyed) { _ in markChanged() }
        .onChange(of: dayType) { _ in markChanged() }
        .onChange(of: coreMemory) { _ in markChanged() }
        .onChange(of: manifestation) { _ in markChanged() }
    }
}

// MARK: - UI Components
extension JournalView {
    
    var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text("Gentle Check-In")
                .font(.system(size: 28, weight: .bold))
            
            Text("Reflect in taps, not paragraphs.")
                .foregroundColor(.secondary)
        }
    }
    
    func questionBlock(
        title: String,
        selection: Binding<String>,
        options: [String]
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            Text(title)
                .font(.headline)
            
            FlexibleButtons(
                options: options,
                selection: selection
            )
        }
        .padding(16)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 22)
        )
    }
    
    func textInputBlock(
        title: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            Text(title)
                .font(.headline)
            
            TextField(
                placeholder,
                text: text
            )
            .padding(14)
            .background(
                Color.gray.opacity(0.08)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 14)
            )
        }
        .padding(16)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 22)
        )
    }
    
    var saveButton: some View {
        
        Group {
            if hasChanges || !isSaved {
                
                Button {
                    saveJournal()
                } label: {
                    Text("Save Reflection 💕")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.pink)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 18)
                        )
                }
                .buttonStyle(.plain)
                
            } else {
                
                Text("Saved ✓")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Logic
extension JournalView {
    
    func markChanged() {
        hasChanges = true
        isSaved = false
    }
    
    func saveJournal() {
        
        // Save to SwiftData / UserDefaults later
        
        isSaved = true
        hasChanges = false
        
        print("Journal Saved") // :contentReference[oaicite:0]{index=0}
    }
}

// MARK: - Reusable Chips
struct FlexibleButtons: View {
    
    let options: [String]
    @Binding var selection: String
    
    var body: some View {
        
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: 120), spacing: 10)
            ],
            spacing: 10
        ) {
            ForEach(options, id: \.self) { item in
                
                Button {
                    selection = item
                } label: {
                    
                    Text(item)
                        .font(.subheadline)
                        .foregroundColor(
                            selection == item
                            ? .pink
                            : .black
                        )
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            selection == item
                            ? Color.pink.opacity(0.12)
                            : Color.gray.opacity(0.08)
                        )
                        .clipShape(
                            RoundedRectangle(cornerRadius: 14)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
