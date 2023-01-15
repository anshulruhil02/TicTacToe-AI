//
//  ContentView.swift
//  TicTacToeAI
//
//  Created by Anshul Ruhil on 2023-01-13.
//

import SwiftUI

struct ContentView: View {
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible()),]
    
    @State private var moves: [Move?] = Array(repeating: nil, count: 9) // We have an optional because a move can only be made if certain conditions are met. if not then it is nil
    
    @State private var  isGameBoardDisabled = false
    @State private var alertItem: AlertItem?
    @State private var selectedLevel = Levels.Easy
    @State private var AIscore = 0;
    @State private var humanScore = 0;
    @State private var drawCount = 0;
    @State private var isEasyMode = true


    var body: some View {
        GeometryReader { geo in // change position acording to screensize
            VStack{
                //background(Color.blue)
                Spacer() // puts the board in middle
                Text("Select the level of AI")
                    .bold()
                    .padding()
                Picker("Level", selection: $selectedLevel ){
                    
                    ForEach(Levels.allCases, id: \.self){ level in
                        Text("\(level.rawValue)")
                    }
                    
                }.pickerStyle(SegmentedPickerStyle())
                .padding()
                .onReceive([selectedLevel].publisher.first()) { level in
                    switch level {
                    case .Easy:
                        isEasyMode = true
                    case .Hard:
                        isEasyMode = false
                    }
                }
                
                
                
                
                
                
                Text("Selected Level: \(selectedLevel.rawValue)")
                    .italic()
                    //.background(selectedLevel == 1 ? Color.green : selectedLevel == 2 ? Color.yellow : selectedLevel == 3 ? Color.orange : Color.red)
                
                
                Spacer()
                
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(0..<9){ i in
                        ZStack{
                            Circle()
                                .foregroundColor(.black)
                                .frame(width: geo.size.width/3 - 15, height: geo.size.width/3 - 15)
                            
                            Image(systemName: moves[i]?.indicator ?? "")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            if isSquareOccupied(in: moves, forIndex: i) {
                                return
                            }
                            moves[i] = Move(player: .human , boardIndex: i)
                            
                            
                            // check for win condition
                            if checkWinCondition(for: .human, in: moves) {
                                alertItem = AlertContext.humanWin
                                humanScore+=1
                                return
                            }
                            
                            // check for draw
                            if checkDraw(in: moves) {
                                alertItem = AlertContext.draw
                                drawCount+=1
                                return
                            }
                            
                            isGameBoardDisabled = true // disables the gameboard for 0.5 seconds which is the delay between human and computer turn
                            // adds delay between player turns
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                                let computerPosition = determineComputerPos(in: moves, level: selectedLevel)
                                moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition)
                                isGameBoardDisabled = false
                                
                                
                                if checkWinCondition(for: .computer, in: moves) {
                                    alertItem = AlertContext.computerWin
                                    AIscore+=1
                                    return
                                }
                                
                                if checkDraw(in: moves) {
                                    alertItem = AlertContext.draw
                                    drawCount+=1
                                    return
                                }
                            }
                        }
                    }
                    
                }
                
                Spacer() // puts the board in middle
                HStack{
                    Spacer()
                    Button(action: {
                        resetGame()
                        AIscore = 0
                        humanScore = 0
                        drawCount = 0
                    }){
                        Text("Reset")
                            .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(5)
                    }
                    
                    Spacer()
                    
                    ZStack{
                        Rectangle()
                            .foregroundColor(.gray).opacity(0.5)
                            .frame(width: geo.size.width/3 , height: geo.size.width/3 - 55)
                        
                        VStack{
                            Text("AI: \(AIscore)")
                                .frame(alignment: .leading)
                                .font(.system(size: 13))
                            Text("Human: \(humanScore)")
                                .frame(alignment: .leading)
                                .font(.system(size: 13))
                            Text("Draw: \(drawCount)")
                                .frame(alignment: .leading)
                                .font(.system(size: 13))
                        }
                        
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            
            .padding()
            .disabled(isGameBoardDisabled)
            .alert(item: $alertItem, content: { alertItem in
                Alert(title: alertItem.title, message: alertItem.message, dismissButton: .default(alertItem.butttonTitle, action:{
                    resetGame()
                }))
            })
            
        }.background(isEasyMode ? Color.green : Color.red)

    }

        
    // returns if a square is occupied
    func isSquareOccupied(in moves: [Move?], forIndex index: Int) -> Bool{
        return moves.contains(where: { $0?.boardIndex == index})
    }
    
    //Logic
    func determineComputerPos(in moves : [Move?], level: Levels) -> Int {
        // let winPatterns: Set<Set<Int>> = [[0,1,2], [3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]
        switch level {
        case .Easy:
            return level1(in: moves)
        case .Hard:
            return level2(in: moves)
        }
    }
    
    func returnRandomSquare() -> Int {
        var movePosition = Int.random(in: 0..<9)
        
        while isSquareOccupied(in: moves, forIndex: movePosition){
            movePosition = Int.random(in: 0..<9)
        }
        return movePosition
    }
    
    func level1(in moves : [Move?]) -> Int {

        let winPatterns: Set<Set<Int>> = [[0,1,2], [3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
        
        let compMoves = moves.compactMap {$0}.filter { $0.player == .computer } //compactMap removes all the nil elements in the move array
        
        let compPos = Set(compMoves.map { $0.boardIndex }) //getting all the player moves in set of Index form so they can be compared
        
        for pattern in winPatterns {
            let winPos = pattern.subtracting(compPos) //Remaining moves that AI would need to win
            
            if winPos.count == 1 {
                let isAvailable = !isSquareOccupied(in: moves, forIndex: winPos.first!)
                if isAvailable { return winPos.first!}
            }
        }
        
        return returnRandomSquare()
    }
    
    
    
    func level2(in moves : [Move?]) -> Int {
        
        let winPatterns: Set<Set<Int>> = [[0,1,2], [3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
        
        let compMoves = moves.compactMap {$0}.filter { $0.player == .computer } //compactMap removes all the nil elements in the move array
        
        let compPos = Set(compMoves.map { $0.boardIndex }) //getting all the player moves in set of Index form so they can be compared
        
        for pattern in winPatterns {
            let winPos = pattern.subtracting(compPos) //Remaining moves that AI would need to win
            
            if winPos.count == 1 {
                let isAvailable = !isSquareOccupied(in: moves, forIndex: winPos.first!)
                if isAvailable { return winPos.first!}
            }
        }
        
        let humanMoves = moves.compactMap {$0}.filter { $0.player == .human } //compactMap removes all the nil elements in the move array
        
        let humanPos = Set(humanMoves.map { $0.boardIndex }) //getting all the player moves in set of Index form so they can be compared
        
        for pattern in winPatterns {
            let winPos = pattern.subtracting(humanPos) //Remaining moves that AI would need to win
            
            if winPos.count == 1 {
                let isAvailable = !isSquareOccupied(in: moves, forIndex: winPos.first!)
                if isAvailable { return winPos.first!}
            }
        }
        
        let centerSquare = 4;
        if !isSquareOccupied(in: moves, forIndex: centerSquare){
            return centerSquare
        }
        return returnRandomSquare()
    }
    
    func checkWinCondition(for player: Player, in moves: [Move?]) -> Bool{
        let winPatterns: Set<Set<Int>> = [[0,1,2], [3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
        
        let playerMoves = moves.compactMap {$0}.filter { $0.player == player } //compactMap removes all the nil elements in the move array
        
        let playerPositions = Set(playerMoves.map { $0.boardIndex }) //getting all the player moves in set of Index form so they can be compared
        
        
        // going through all the winpattern moves and comparing it with moves of our player
        for pattern in winPatterns where pattern.isSubset(of: playerPositions){
            return true
        }
        
        return false
    }
    
    func checkDraw(in moves: [Move?]) -> Bool {
        return moves.compactMap {$0}.count == 9
    }
    
    func resetGame(){
        moves = Array(repeating: nil, count: 9)
    }
}

enum Player {
    case human, computer
}

struct Move {
    let player: Player
    let boardIndex: Int
    
    var indicator: String{
        return player == .human ? "xmark" : "circle"
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


enum Levels: String, CaseIterable {
    case Easy
    case Hard
}
