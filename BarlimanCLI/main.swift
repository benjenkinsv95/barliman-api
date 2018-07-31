#!/usr/bin/swift
//
//  main.swift
//  BarlimanCLI
//
//  Created by Ben J on 7/29/18.
//  Copyright © 2018 Ben Jenkins. All rights reserved.
//

import Foundation

let testSuiteJson = CommandLine.arguments[1]
let testSuite = TestLoader.load(fromJson: testSuiteJson)

logger.info("Definition text")
logger.info(testSuite.definitionText)

let codeRunner = CodeRunner()
let possibleBestGuess = codeRunner.runCode(definitionText: testSuite.definitionText,
        interpreterSemantics: semantics,
        tests: testSuite.tests)


if let bestGuess = possibleBestGuess {
    logger.info("Best guess is")
    print(bestGuess)
} else {
    print("Failed to calculate best guess.", to: &errStream)
}

