//
//  SettingView.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 01/12/24.
//

import SwiftUI

struct SettingView: View {
    let sortType: SortType
    let selectedAutoClearType: AutoClearMenuEnum
    
    @Binding var isShortcutEnabled: Bool
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State var showDeleteAlert: Bool
    @State var textColor: Color = Color("TextColor")
    
    @Binding var selectedLeftColor: Color
    @Binding var selectedRightColor: Color
    @Binding var selectedFontColor: Color
    
    let updateAutoClearSetting: (_ setting: AutoClearMenuEnum) -> Void
    let updateItem: (_ sortType: SortType) -> Void
    let saveToFile: () -> Void
    let importFromFile: () -> Void
    let clearAllData: () -> Void
    let setShortcutEnabled: (Bool) -> Void
    
    var body: some View {
        VStack {
    
            settingsTextView(text: "Setting")
                .font(.headline)
            HStack {
                settingsTextView(text: "Enable Shortcut")
                Spacer()
                Toggle("", isOn: $isShortcutEnabled)
                    .toggleStyle(SwitchToggleStyle())
                    .padding()
                    .onChange(of: isShortcutEnabled) { enabled in
                        setShortcutEnabled(enabled)
                    }
            }
            
            HStack {
                settingsTextView(text: "Dark Mode")
                Spacer()
                Toggle("", isOn: $isDarkMode)
                    .toggleStyle(SwitchToggleStyle())
                    .padding()
            }
            
            HStack {
                settingsTextView(text: "Auto Clear History")
                Spacer()
                Menu (selectedAutoClearType.rawValue) {
                    Button("None") {
                        updateAutoClearSetting(.none)
                    }
                    Button("24 Hours") {
                        updateAutoClearSetting(.oneDay)
                    }
                    Button("7 Days") {
                        updateAutoClearSetting(.sevenDay)
                    }
                }.padding()
            }
            
            HStack {
                settingsTextView(text: "Sort Type")
                Spacer()
                Menu (sortType.rawValue) {
                    Button("Date Time") {
                        updateItem(.dateTime)
                    }
                    Button("Alphabet") {
                        updateItem(.alphabet)
                    }
                }.padding()
            }
            
            HStack {
                settingsTextView(text: "Export")
                Spacer()
                Button(action: {
                    saveToFile()
                }) {
                    Text("Save To File")
                }.padding()
            }
            
            HStack {
                settingsTextView(text: "Import")
                Spacer()
                Button(action: {
                    importFromFile()
                }) {
                    Text("Import From File")
                }.padding()
            }
            
            HStack {
                settingsTextView(text: "Base Color")
                Spacer()
                ColorPicker("", selection: $selectedLeftColor).padding(.horizontal)
            }
            
            HStack {
                settingsTextView(text: "Sidebar Color")
                Spacer()
                ColorPicker("", selection: $selectedRightColor).padding(.horizontal)
            }
            
            HStack {
                settingsTextView(text: "Font Color")
                Spacer()
                ColorPicker("", selection: $selectedFontColor).padding(.horizontal)
            }
            
            Button(action: {
                showDeleteAlert = true
            }) {
                Text("Delete all shortcut")
                    .foregroundColor(.red)
                    .padding()
            }
            .buttonStyle(PlainButtonStyle())
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Warning"),
                    message: Text("Peak Atlas will delete all your saved copied items ! This action is irreversible"),
                    primaryButton: .default(Text("Cancel")) {
                    },
                    secondaryButton: .destructive(Text("Delete Now")) {
                        clearAllData()
                    }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func settingsTextView(text: String) -> some View {
        Text(text)
            .padding(.leading, 10)
            .foregroundColor(textColor)
    }
}
