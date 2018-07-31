//
// Created by Ben J on 7/31/18.
// Copyright (c) 2018 Ben Jenkins. All rights reserved.
//

import Foundation

public struct StderrOutputStream: TextOutputStream {
    public mutating func write(_ string: String) { fputs(string, stderr) }
}
var errStream = StderrOutputStream()

let logger = Logger()
fileprivate let level = Level.none
enum Level: Int {
    case none = 0
    case trace = 1
    case info = 2
    case warn = 3
    case error = 4

}

class Logger {
    func info(_ message: String) {
        guard level.rawValue >= Level.info.rawValue else {
            return
        }
        print("[info] \(message)")
    }

    func warn(_ message: String) {
        guard level.rawValue >= Level.warn.rawValue else {
            return
        }
        print("[warn] \(message)")
    }

    func error(_ message: String) {
        guard level.rawValue >= Level.error.rawValue else {
            return
        }
        print("[error] \(message)", to: &errStream)
    }
}
