//
//  HeaderView.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 04/12/24.
//

import SwiftUI

struct HeaderView: View {
    @Binding var viewModel: ClipboardItemViewModel
    var body: some View {
        HStack {
            Text("Peak Clipboard")
                .font(.headline)
                .foregroundColor(Color("TextColor"))
                .padding(.init(top: 10, leading: 10, bottom: 0, trailing: 10))
            
            Spacer()
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    if viewModel.isShowSetting {
                        viewModel.isShowDetail = false
                        viewModel.isShowCollection = false
                        viewModel.isShowSidebar = false
                        viewModel.isShowSetting = false
                    } else {
                        viewModel.isShowDetail = false
                        viewModel.isShowCollection = false
                        viewModel.isShowSidebar = true
                        viewModel.isShowSetting = true
                    }
                }
            }) {
                Image("Gear", bundle: nil)
                    .foregroundColor(.gray)
            }.buttonStyle(BorderlessButtonStyle())
                .padding(.trailing, 8)
            
            Button(action: {
                withAnimation(.easeInOut(duration: 1.0)) {
                    viewModel.hideAllSidebarTypes()
                }
            }) {
                Image("SidebarSimple", bundle: nil)
                    .foregroundColor(.gray)
            }.buttonStyle(BorderlessButtonStyle())
                .padding(.trailing, 20)
            
        }.padding(.init(top: 12, leading: 12, bottom: 12, trailing: 0))
    }
}
