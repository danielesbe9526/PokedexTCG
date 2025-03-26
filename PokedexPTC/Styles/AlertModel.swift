//
//  AlertModel.swift
//  ContriesAPI
//
//  Created by Daniel Beltran on 15/02/24.
//

import Foundation
import SwiftUI

public struct AlertModel {
    public var title: String
    public var message: String?
    public var mainButtonTitle: String?
    public var secondButtonTitle: String?
    public var mainButtonAction: (() -> Void)?
    public var secondButtonAction: (() -> Void)?
    
    public init(title: String, message: String? = nil, mainButtonTitle: String? = nil, secondButtonTitle: String? = nil, mainButtonAction: (() -> Void)? = nil, secondButtonAction: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.mainButtonTitle = mainButtonTitle
        self.secondButtonTitle = secondButtonTitle
        self.mainButtonAction = mainButtonAction
        self.secondButtonAction = secondButtonAction
    }
    
    public init() {
        self.title = ""
        self.message = nil
        self.mainButtonTitle = ""
        self.secondButtonTitle = nil
        self.mainButtonAction = nil
        self.secondButtonAction = nil
    }
}

extension AlertModel {
    static func defaultAlert(mainButtonAction: (() -> Void)? = nil) -> AlertModel {
        AlertModel(title: "ERROR",
                   message: "Some error Appear",
                   mainButtonTitle: "got it",
                   mainButtonAction: mainButtonAction)
    }
    
    static func requestError(codeError: Int, mainButtonAction: (() -> Void)?, secondButtonAction: (() -> Void)?) -> AlertModel {
        switch codeError {
        case 300...400:
            return AlertModel(title: "🆘 Invalid response 🆘",
                              message: "We are having some issues, please contact us.",
                              mainButtonTitle: "got it",
                              secondButtonTitle: "retry",
                              mainButtonAction: mainButtonAction,
                              secondButtonAction: secondButtonAction)
        case 500...600:
            return AlertModel(title: "🚧 Server Error 🚧",
                              message: "Invalid response, check your internet conection or try again latter.",
                              mainButtonTitle: "got it",
                              secondButtonTitle: "retry",
                              mainButtonAction: mainButtonAction,
                              secondButtonAction: secondButtonAction)
        default:
            return AlertModel(title: "☠️ Unexpected error ☠️",
                              message: "We are having some issues, please contact us.",
                              mainButtonTitle: "got it",
                              mainButtonAction: mainButtonAction)
        }
    }
}
