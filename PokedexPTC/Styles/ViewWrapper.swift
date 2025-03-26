//
//  ViewWrapper.swift
//  ContriesAPI
//
//  Created by Daniel Beltran on 15/02/24.
//

import SwiftUI

public struct ViewWrapper<Content: View>: View {
    @Binding var spinerRun: Bool
    @Binding var alertModel: AlertModel?
    
    var content: () -> Content
    var title: String
    var naviagtionBarTitleDisplayMode: () -> NavigationBarItem.TitleDisplayMode
    
    public init(spinerRun: Binding<Bool> = .constant(false),
                alertModel: Binding<AlertModel?> = .constant(nil),
                title: String = "",
                naviagtionBarTitleDisplayMode: @escaping () -> NavigationBarItem.TitleDisplayMode = { .inline },
                @ViewBuilder content: @escaping () -> Content) {
        self._spinerRun = spinerRun
        self._alertModel = alertModel
        self.title = title
        self.naviagtionBarTitleDisplayMode = naviagtionBarTitleDisplayMode
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            content()
            if let alertModel {
                Alert(showView: true, model: alertModel)
                    .zIndex(9)
            }

            if spinerRun {
                ProgressView()
                    .frame(width: 45.0, height: 45.0)
            }
        }
        .padding(.top, 5)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(naviagtionBarTitleDisplayMode())
    }
}
