//
//  RunSchemeOperation.swift
//  Barliman
//
//  Created by William Byrd on 5/24/16.
//  Copyright © 2016 William E. Byrd.
//  Released under MIT License (see LICENSE file)

import Foundation
// TODO: Remove this dependency. :P
import Cocoa

class RunSchemeOperation: Operation {

    var codeRunner: CodeRunner
    var schemeScriptPathString: String
    var task: Process
    var taskType: String

    let kIllegalSexprString = "Illegal sexpression"
    let kParseErrorString = "Syntax error"
    let kEvaluationFailedString = "Evaluation failed"
    let kThinkingString = "???"
    let test: SchemeTest?


    init(codeRunner: CodeRunner, schemeScriptPathString: String, taskType: String, test: SchemeTest? = nil) {
        self.codeRunner = codeRunner
        self.schemeScriptPathString = schemeScriptPathString
        self.task = Process()
        self.taskType = taskType
        self.test = test
    }

    override func cancel() {
        logger.warn("!!! cancel called!")

        super.cancel()

        // print("&&& killing process \( task.processIdentifier )")
        task.terminate()
        // print("&&& killed process")

    }

    func illegalSexpInDefn() {

        // update the user interface, which *must* be done through the main thread
        OperationQueue.main.addOperation {
            logger.error(self.kIllegalSexprString)
        }
    }

    func parseErrorInDefn() {

        // update the user interface, which *must* be done through the main thread
        OperationQueue.main.addOperation {

            logger.error(self.kParseErrorString)

            // Be polite and cancel the allTests operation as well, since it cannot possibly succeed
            self.codeRunner.schemeOperationAllTests?.cancel()
        }
    }


    override func main() {

        if self.isCancelled {
            // print("*** cancelled immediately! ***\n")
            return
        }

        runSchemeCode()
        
    }


    func runSchemeCode() {

        // If we move to only support macOS 10.12, can use the improved time difference code adapted from JeremyP's answer to http://stackoverflow.com/questions/24755558/measure-elapsed-time-in-swift.  Instead we'll use JeremyP's NSDate version instead.
        let startTime = Date();


        // Path to Chez Scheme
        // Perhaps this should be settable in a preferences panel.
        task.launchPath = "/usr/local/bin/scheme"

        // Arguments to Chez Scheme
        task.arguments = ["--script", self.schemeScriptPathString]

        let outputPipe = Pipe()
        let errorPipe = Pipe()

        task.standardOutput = outputPipe
        task.standardError = errorPipe

        // Launch the Chez Scheme process, with the miniKanren query
        task.launch()
        // print("*** launched process \( task.processIdentifier )")


        let outputFileHandle = outputPipe.fileHandleForReading
        let errorFileHandle = errorPipe.fileHandleForReading

        let data = outputFileHandle.readDataToEndOfFile()
        let errorData = errorFileHandle.readDataToEndOfFile()

        // wait until the miniKanren query completes
        // (or until the task is killed because the operation is cancelled)
        task.waitUntilExit()

        // we need the exit status of the Scheme process to know if Chez choked because of a syntax error (for a malformed query), or whether Chez exited cleanly
        let exitStatus = task.terminationStatus

        // update the user interface, which *must* be done through the main thread
//        OperationQueue.main.addOperation {

            func setFontAndSize(_ bestGuessView: NSTextView?) {
            }
            
            func onTestCompletion(_ inputField: NSTextField, outputField: NSTextField, spinner: NSProgressIndicator, label: NSTextField, datastring: String) {

                if datastring == "illegal-sexp-in-test/answer" {

                    logger.error(self.kIllegalSexprString)

                    // Be polite and cancel the allTests operation as well, since it cannot possibly succeed
                    self.codeRunner.schemeOperationAllTests?.cancel()
                } else if datastring == "parse-error-in-test/answer" {
                    logger.error(self.kParseErrorString)

                    // Be polite and cancel the allTests operation as well, since it cannot possibly succeed
                    self.codeRunner.schemeOperationAllTests?.cancel()
                } else if (datastring == "illegal-sexp-in-defn" || datastring == "parse-error-in-defn") {
                    // The definition is messed up.  We don't really know the state of the test.
                    // We represent this in the UI as the ??? "thinking" string without the spinner


                    logger.info(self.kThinkingString)
                } else if datastring == "()" { // parsed, but evaluator query failed!
                    onTestFailure(inputField, outputField: outputField, label: label)
                } else { // parsed, and evaluator query succeeded!
                    onTestSuccess(inputField, outputField: outputField, label: label)
                }
            }

            func onTestSuccess(_ inputField: NSTextField, outputField: NSTextField, label: NSTextField) {
                let endTime = Date();
                let timeInterval: Double = endTime.timeIntervalSince(startTime);
                // formatting from realityone's answer to http://stackoverflow.com/questions/24051314/precision-string-format-specifier-in-swift
                label.stringValue = String(format: "Succeeded (%.2f s)",  timeInterval)
            }

            func onTestFailure(_ inputField: NSTextField, outputField: NSTextField, label: NSTextField) {
                let endTime = Date();
                let timeInterval: Double = endTime.timeIntervalSince(startTime);

                // formatting from realityone's answer to http://stackoverflow.com/questions/24051314/precision-string-format-specifier-in-swift
                logger.info(String(format: "Failed (%.2f s)",  timeInterval))

                // Be polite and cancel the allTests operation as well, since it cannot possibly succeed
                self.codeRunner.schemeOperationAllTests?.cancel()
            }

            func onTestSyntaxError(_ inputField: NSTextField, outputField: NSTextField, spinner: NSProgressIndicator, label: NSTextField) {
                logger.error( self.kIllegalSexprString)
            }

            func onBestGuessSuccess(_ bestGuessView: NSTextView?, label: NSTextField?, guess: String) {
                let endTime = Date();
                let timeInterval: Double = endTime.timeIntervalSince(startTime);

                if (guess == "illegal-sexp-in-defn" ||
                    guess == "parse-error-in-defn" ||
                    guess == "illegal-sexp-in-test/answer" ||
                    guess == "parse-error-in-test/answer") {
                    // someone goofed!
                    // we just don't know what to do!

                    bestGuessView?.textStorage?.setAttributedString(NSAttributedString(string: "" as String))
                    setFontAndSize(bestGuessView)
                    
                    logger.info(self.kThinkingString)

                } else { // success!

                    logger.info("Best Guess Found!")
                    logger.info(guess)
                    codeRunner.bestGuessInProgress = guess
                    bestGuessView?.textStorage?.setAttributedString(NSAttributedString(string: guess))
                    setFontAndSize(bestGuessView)

                    label?.stringValue = String(format: "Succeeded (%.2f s)",  timeInterval)

                    // Be polite and cancel all the other tests, since they must succeed!
                    self.codeRunner.cancelAllOperations()
                }
            }

            func onBestGuessFailure(_ bestGuessView: NSTextView?, label: NSTextField?) {
                let endTime = Date();
                let timeInterval: Double = endTime.timeIntervalSince(startTime);

                bestGuessView?.textStorage?.setAttributedString(NSAttributedString(string: "" as String))
                setFontAndSize(bestGuessView)
                
                logger.info(String(format: "Failed (%.2f s)",  timeInterval))

                // Be polite and cancel all the other tests, since they must succeed!
                self.codeRunner.cancelAllOperations()
            }

            func onBestGuessKilled(_ bestGuessView: NSTextView?, label: NSTextField?) {
                bestGuessView?.textStorage?.setAttributedString(NSAttributedString(string: "" as String))
                setFontAndSize(bestGuessView)

                label?.stringValue = ""
            }

            // syntax error was caused by the main code or a test, not by the best guess!
            func onSyntaxErrorBestGuess(_ bestGuessView: NSTextView?, label: NSTextField?) {
                label?.stringValue = ""
            }




            let datastring = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
            let errorDatastring = NSString(data: errorData, encoding: String.Encoding.utf8.rawValue)! as String
            let taskType = self.taskType
            
            if exitStatus == 0 {
                // at least Chez ran to completion!  The query could still have failed, of course
                if self.taskType == "simple" {
                    if datastring == "parse-error-in-defn" {
                        self.parseErrorInDefn()
                    } else if datastring == "illegal-sexp-in-defn" {
                        self.illegalSexpInDefn()
                    } else if datastring == "()" {

                        logger.info(self.kEvaluationFailedString)

                        // Be polite and cancel the allTests operation as well, since it cannot possibly succeed
                        self.codeRunner.schemeOperationAllTests?.cancel()
                    }
                }

                if let testView = self.test?.view {
                    onTestCompletion(testView.inputField,
                            outputField: testView.expectedOutputField,
                            spinner: testView.spinner,
                            label: testView.statusLabel, datastring: datastring)

                }

                if self.taskType == "allTests" {
                    if datastring == "fail" {
                        onBestGuessFailure(nil, label: nil)
                    } else {
                        onBestGuessSuccess(nil, label: nil, guess: datastring)
                    }
                }
            } else if exitStatus == 15 {
                // SIGTERM exitStatus
                logger.error("SIGTERM !!!  taskType = \( self.taskType )")

                // allTests must have been cancelled by a failing test, meaning there is no way for allTests to succeed
                if self.taskType == "allTests" {
                    onBestGuessKilled(nil, label: nil)
                }

                // individual tests must have been cancelled by allTests succeeding, meaning that all the individual tests should succeed
                if let testView = self.test?.view {
                    onTestSuccess(testView.inputField,
                            outputField: testView.expectedOutputField,
                            label: testView.statusLabel)
                }

            } else {
                // the query wasn't even a legal s-expression, according to Chez!
                if self.taskType == "simple" {
                    // print("exitStatus = \( exitStatus )")
                    self.illegalSexpInDefn()
                }

                if let testView = self.test?.view {
                    onTestSyntaxError(testView.inputField,
                            outputField: testView.expectedOutputField,
                            spinner: testView.spinner,
                            label: testView.statusLabel)
                }

                if taskType == "allTests" {
                    onSyntaxErrorBestGuess(nil, label: nil)
                }
            }

            logger.info("datastring for process \( self.task.processIdentifier ): \(datastring)")
            logger.error("error datastring for process \( self.task.processIdentifier ): \(errorDatastring)")
        }
//    }
}
