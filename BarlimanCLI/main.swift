#!/usr/bin/swift
//
//  main.swift
//  BarlimanCLI
//
//  Created by Ben J on 7/29/18.
//  Copyright © 2018 Ben Jenkins. All rights reserved.
//

import Foundation

//let definitionText = CommandLine.arguments[1]
let definitionText = "(define ,A (lambda ,B ,C))"
logger.info("Definition text")
logger.info(definitionText)

let test1 = SchemeTest(input: "(append '(,g1) '(,g2))", output: "`(,g1 ,g2)", id: 1)
let test2 = SchemeTest(input: "(append '(,g3 ,g4) '())", output: "`(,g3 ,g4)", id: 2)

let codeRunner = CodeRunner()
let possibleBestGuess = codeRunner.runCode(definitionText: definitionText, interpreterSemantics: semantics, tests: [test1, test2])


if let bestGuess = possibleBestGuess {
    logger.info("Best guess is")
    print(bestGuess)
} else {
    print("Failed to calculate best guess.")
}

