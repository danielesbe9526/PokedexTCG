//
//  CardView.swift
//  ContriesAPI
//
//  Created by Daniel Beltran on 19/02/24.
//

import SwiftUI

public struct CardView<Content: View> : View {
    var content: () -> Content
    
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color("alert"))
                .padding(5)
                .shadow(color: .black.opacity(0.2), radius: 3, x: 2, y: 2)
            
            content()
        }
    }
}
