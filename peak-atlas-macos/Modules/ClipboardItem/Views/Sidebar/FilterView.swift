//
//  FilterView.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 30/11/24.
//

import SwiftUI

struct FilterView: View {
    @State private var selectedStartDate = Date()
    @State private var selectedEndDate = Date()
    @State private var isDateFilter = false
    @State private var selectedFileTypes: Set<Int> = []
    
    let applyFilter: (Date?, Date?, Set<Int>) -> Void
    
    init(applyFilter: @escaping (Date?, Date?, Set<Int>) -> Void) {
        self.applyFilter = applyFilter
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Filter").font(.interRegular(14)).padding(.top, 20)
            
            HStack {
                Text("Filter By Type")
                Spacer()
                Menu("Choose File Types") {
                    Button(action: {
                        toggleFileType(1)
                    }) {
                        HStack {
                            Text("Text")
                            if selectedFileTypes.contains(1) {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    
                    Button(action: {
                        toggleFileType(4)
                    }) {
                        HStack {
                            Text("URL")
                            if selectedFileTypes.contains(4) {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    
                    Button(action: {
                        toggleFileType(3)
                    }) {
                        HStack {
                            Text("Image")
                            if selectedFileTypes.contains(3) {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }.padding()
            
            if isDateFilter {
                HStack {
                    Text("Date Start")
                    Spacer()
                    DatePicker(
                        "",
                        selection: $selectedStartDate,
                        displayedComponents: .date
                    ).datePickerStyle(CompactDatePickerStyle())
                }.padding()
                
                HStack {
                    Text("Date End")
                    Spacer()
                    DatePicker(
                        "",
                        selection: $selectedEndDate,
                        displayedComponents: .date
                    ).datePickerStyle(CompactDatePickerStyle())
                }.padding()
            } else {
                Button(action: {
                    isDateFilter = true
                }) {
                    Text("Add Date Filter")
                        .foregroundColor(.white)
                        .padding()
                }.buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    .padding(.top, 8)
            }
            
            Spacer()
            
            Button(action: {
                applyFilter(
                    isDateFilter ? selectedStartDate : nil,
                    isDateFilter ? selectedEndDate : nil,
                    selectedFileTypes
                )
            }) {
                Text("Apply Filter")
                    .foregroundColor(.white)
                    .padding()
            }.buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                .padding(.bottom, 16)
                .frame(height: 20)
            
            Button(action: {
                resetFilters()
            }) {
                Text("Remove All Filters")
                    .foregroundColor(.red)
                    .padding()
            }.buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                .padding(.bottom, 16)
        }
    }
    
    private func toggleFileType(_ type: Int) {
        if selectedFileTypes.contains(type) {
            selectedFileTypes.remove(type)
        } else {
            selectedFileTypes.insert(type)
        }
    }
    
    private func resetFilters() {
        isDateFilter = false
        selectedStartDate = Date()
        selectedEndDate = Date()
        selectedFileTypes.removeAll()
        
        applyFilter(nil, nil, [])
    }
}

#Preview {
    FilterView(applyFilter: { startDate, endDate, fileTypes in
        print("Start Date: \(startDate?.description ?? "nil")")
        print("End Date: \(endDate?.description ?? "nil")")
        print("File Types: \(fileTypes)")
    })
}
