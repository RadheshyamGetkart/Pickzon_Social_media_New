//
//  AddPhotosPopupView.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 21/01/26.
//  Copyright © 2026 Pickzon Inc. All rights reserved.
//

import SwiftUI

struct AddPhotosPopupView: View {

    var onPostNow: () -> Void
    var onPostLater: () -> Void
    var onClose: () -> Void
    let imgUrl:String
    var body: some View {
        ZStack {

            // Dim background
            Color.black.opacity(0.55)
                .ignoresSafeArea()
//                .onTapGesture {
//                    onClose()
//                }

            VStack {
              //  ZStack(alignment: .topTrailing) {

                    // 🔥 FULL IMAGE CARD
                    
                    AsyncImage(url: URL(string: imgUrl)) { img in
                        
                        img.resizable()
                            .scaledToFit()
                            //.frame(height: 360)
                            //.frame(minWidth: 200, minHeight:200)
                           
                        
                    } placeholder: {
                        Image("dummy").resizable().aspectRatio(contentMode: .fill).frame(width: 300, height:300)
                    }

                   // Image("add_photos_popup")
//                        .resizable()
//                        .scaledToFill()
//                        .frame(height: 360)
//                        .clipShape(RoundedRectangle(cornerRadius: 28))

                    // Close button
//                    Button {
//                        onClose()
//                    } label: {
//                        Image(systemName: "xmark")
//                            .foregroundColor(.white)
//                            .padding(12)
//                    }
//                }

                // Buttons
                HStack(spacing: 10) {
                    
                    Button(action: {
                        onPostNow()
                    }) {
                        Text("Post Now")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .background(Color(Themes.sharedInstance.colorWithHexString(hex: "#00BDB0")))
                            .cornerRadius(12)
                    }

                    Button(action: {
                        onPostLater()
                    }) {
                        Text("Post Later")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 15).padding(.bottom, 20).padding(.horizontal,10)
            }
            
            .background(Color(.systemBackground))
            .cornerRadius(32)
            .padding(24)
            //.frame(maxWidth: UIScreen.ft_width(), maxHeight: UIScreen.ft_width()+40)
        }
        .transition(.scale.combined(with: .opacity))
    }
}
