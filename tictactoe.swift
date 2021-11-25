//
//  main.swift
//  Playground Command Line
//
//  Created by Ethan Stein on 11/22/21.
//

import Foundation

let pieces = [
    "player": "😜 ",
    "computer": "🤖 ",
    "spaces": " . "
]

var board = Array(repeating: Array(repeating: pieces["spaces"]!, count: 3), count: 3)

var cpuSpecMove: [String: Int] = ["x": -1, "y": -1]

func readInt() -> Int {
    var s:String? = readLine()
    
    while(Int(s!) == nil) {
        print("Invalid Input!")
        s = readLine()
    }
    
    let i:Int? = Int(s!)
    return i!
}

func printBoard(board: [[String]]) {
    for row in board {
        print(row[0], row[1], row[2])
    }
    
    print("\n")
}

class State {
    var verts: Array<[String: Int]>
    var occupied: Array<Bool> = []
    
    func isOccupied(board: [[String]], user: String) -> Bool {
        for vert in self.verts {
            board[vert["x"]!][vert["y"]!] == pieces[user] ? self.occupied.append(true) : self.occupied.append(false)
        }
        
        return self.occupied[0] && self.occupied[1] && self.occupied[2]
    }
    
    
    init(verts: Array<[String: Int]>) {
        self.verts = verts
    }
}

func genStates () -> [String: Array<State>] {
    var verts: Array<[[String:Int]]> = [
        [
            ["x": 0 , "y": 0],
            ["x": 1 , "y": 1],
            ["x": 2 , "y": 2]
        ],
        
        [
            ["x": 0 , "y": 2],
            ["x": 1 , "y": 1],
            ["x": 2 , "y": 0]
        ]
    ]
    
    for index in 0...2 {
        verts.append([
            ["x": index , "y": 0],
            ["x": index , "y": 1],
            ["x": index , "y": 2]
        ])
        
        verts.append([
            ["x": 0, "y": index],
            ["x": 1, "y": index],
            ["x": 2, "y": index]
        ])
    }
    
    var states: [String: Array<State>] = [
        "player": [],
        "computer": []
    ]
    
    for user in ["player", "computer"] {
        for vert in verts {
            states[user]!.append(State(verts: vert))
        }
    }
    
    return states
    
}

func findSpecMove (playerState: Array<State>) {
    for state in playerState {
        var count:Int = 0
        
        for o in state.occupied {
            if (o) {
                count += 1
            }
        }
        
        if (count == 2) {
            let falseVertex = state.verts[state.occupied.firstIndex(of: false)!]
            
            if (board[falseVertex["x"]!][falseVertex["y"]!] == pieces["spaces"]) {
                cpuSpecMove = state.verts[state.occupied.firstIndex(of: false)!]
            }
        }
    }
}

func checkWin (states: [String: Array<State>]) -> String {
    var winner:String = ""
    
    for user in ["player", "computer"] {
        for state in states[user]! {
            if (state.isOccupied(board: board, user: user)){
                winner = user
            }
        }
    }
    
    var count:Int = 0
    
    for i in 0...(states["player"]!.count - 1) {
        if (states["player"]![i].occupied.contains(true) && states["computer"]![i].occupied.contains(true)) {
            count += 1
        }
    }
    
    if (count == 8) {
        winner = "tie"
    }
    
    return winner
}

func turn(type: String, board: [[String]]) -> [[String]] {
    var mutBoard = board
    
    switch type {
    case "player":
        var playerMove: [String: Int] = [:]
        
        func getMove() {
            print("x: ", terminator: "")
            playerMove["x"] = readInt()
            
            print("y: ", terminator: "")
            playerMove["y"] = readInt()
        }
        
        getMove()
        
        while(
              playerMove["x"]! > 2 || playerMove ["y"]! > 2 ||
              playerMove["x"]! < 0 || playerMove ["y"]! < 0 ||
              mutBoard[playerMove["y"]!][playerMove["x"]!] != pieces["spaces"]!
        ) {
            print("Invalid space!")
            getMove()
        }
        
        mutBoard[playerMove["y"]!][playerMove["x"]!] = pieces["player"]!
        
    case "computer":
        if (cpuSpecMove["x"]! != -1 && Int.random(in: 1...5) > 1) {
            mutBoard[cpuSpecMove["x"]!][cpuSpecMove["y"]!] = pieces["computer"]!
            
            cpuSpecMove = ["x": -1, "y": -1]
        } else {
            var cpuMove: [String: Int] = [
                "x": Int.random(in: 0...2),
                "y": Int.random(in: 0...2)
            ]
            
            while(mutBoard[cpuMove["y"]!][cpuMove["x"]!] != pieces["spaces"]!) {
                cpuMove["x"] = Int.random(in: 0...2)
                cpuMove["y"] = Int.random(in: 0...2)
            }
            
            mutBoard[cpuMove["x"]!][cpuMove["y"]!] = pieces["computer"]!
        }
        
    default:
        return mutBoard
    }
    
    return mutBoard
}

printBoard(board: board)

var states = genStates()
findSpecMove(playerState: states["player"]!)
var winner = checkWin(states: states)

while (winner == "") {
    board = turn(type: "player", board: board)
    
    states = genStates()
    winner = checkWin(states: states)
    
    findSpecMove(playerState: states["player"]!)
    
    board = turn(type: "computer", board: board)
    printBoard(board: board)
    
    states = genStates()
    winner = checkWin(states: states)
}

if (winner != "tie") {
    print("\(pieces[winner]!)wins! 🎉")
} else if (winner != "") {
    print("Tie! 🪢")
}
