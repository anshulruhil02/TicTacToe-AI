//
//  alerts.swift
//  TicTacToeAI
//
//  Created by Anshul Ruhil on 2023-01-13.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    var title: Text
    var message: Text
    var butttonTitle: Text
}

struct AlertContext {
    static let humanWin = AlertItem(title: Text("You win!") ,
                             message: Text("You beat the AI!"),
                             butttonTitle: Text("Go again?"))
    
    static let computerWin = AlertItem(title: Text("computer wins!") ,
                             message: Text("AI will take over the world !"),
                             butttonTitle: Text("Try again?"))
    
    static let draw = AlertItem(title: Text("Draw") ,
                             message: Text("Not bad"),
                             butttonTitle: Text("Try again?"))
}

