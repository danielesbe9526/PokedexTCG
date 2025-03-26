//
//  Alert.swift
//  ContriesAPI
//
//  Created by Daniel Beltran on 15/02/24.
//

import SwiftUI

public struct Alert: View {
    @State private var showView: Bool

    var model: AlertModel
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            if showView {
                alertBody
                    .frame(
                        width: UIScreen.main.bounds.width * 0.9,
                        height: UIScreen.main.bounds.height * 0.3
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .top),
                        removal: .move(edge: .top)
                    ))
                    .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                    .onTapGesture {
                        withAnimation {
                            self.showView = false
                        }
                    }.onAppear(perform: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation {
                                self.showView = false
                            }
                        }
                    })
            }
        }.offset(y: -UIScreen.main.bounds.height * 0.35)
    }
    
    public init(showView: Bool, model: AlertModel) {
        self.showView = showView
        self.model = model
    }
    
    public var alertBody: some View {
        return Label(model.title, systemImage: "antenna.radiowaves.left.and.right.slash")
            .fontWeight(.bold)
            .padding()
            .background(.red)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

#Preview {
    Alert(showView: true, model: AlertModel(title: "title", mainButtonTitle: "button", mainButtonAction: nil))
}
