//
// Created by Ben J on 7/29/18.
// Copyright (c) 2018 William E. Byrd. All rights reserved.
//

import Foundation

class CodeRunner {

    var schemeOperationAllTests: RunSchemeOperation?
    var bestGuessInProgress: String?
    let runSchemeOperationQueue: OperationQueue = OperationQueue()

    var operationCount: Int {
        return runSchemeOperationQueue.operationCount
    }

    func cancelAllOperations() {
        runSchemeOperationQueue.cancelAllOperations()
    }

    func waitUntilAllOperationsAreFinished() {
        runSchemeOperationQueue.waitUntilAllOperationsAreFinished()
    }

    func runCode(definitionText: String,
                 interpreterSemantics: String,
                 tests: [SchemeTest]) -> String? {
        // see how many operations are currently in the queue
        print("operation count: \(runSchemeOperationQueue.operationCount)")
        runSchemeOperationQueue.cancelAllOperations()

        
        let bundle = Bundle.main
        let mk_vicare_path: NSString? = bundle.path(forResource: "mk-vicare", ofType: "scm", inDirectory: "mk-and-rel-interp/mk") as NSString?
        let mk_path: NSString? = bundle.path(forResource: "mk", ofType: "scm", inDirectory: "mk-and-rel-interp/mk") as NSString?


        // write the Scheme code containing the miniKanren query to a temp file
        let query_simple_for_mondo_scheme_file = "barliman-query-simple-for-mondo-scheme-file.scm"

        // files that load query code
        let new_query_file_simple = "barliman-new-query-simple.scm"

        let new_query_file_alltests = "barliman-new-query-alltests.scm"

        // files containing the actual query code

        let new_query_file_actual_alltests = "barliman-new-query-actual-alltests.scm"

        let mk_vicare_path_string = mk_vicare_path! as String
        let mk_path_string = mk_path! as String

        let load_mk_vicare_string: String = "(load \"\(mk_vicare_path_string)\")"
        let load_mk_string: String = "(load \"\(mk_path_string)\")"


        let querySimpleForMondoSchemeContents: String = makeQuerySimpleForMondoSchemeFileString(interpreterSemantics,
                definitionText: definitionText,
                mk_vicare_path_string: mk_vicare_path_string,
                mk_path_string: mk_path_string)





        let newAlltestsActualQueryString = makeAllTestsQueryString(definitionText: definitionText,
                tests: tests)


        // adapted from http://stackoverflow.com/questions/26573332/reading-a-short-text-file-to-a-string-in-swift
        let new_simple_query_template: String? = bundle.path(forResource: "barliman-new-simple-query-template", ofType: "swift", inDirectory: "mk-and-rel-interp")

        let new_simple_query_template_string: String
        do {
            new_simple_query_template_string = try String(contentsOfFile: new_simple_query_template!)
        } catch {
            print("!!!!!  LOAD_ERROR -- can't load new_simple_query_template\n")
            new_simple_query_template_string = ""
        }


        // adapted from http://stackoverflow.com/questions/26573332/reading-a-short-text-file-to-a-string-in-swift
        let new_test_query_template: String? = bundle.path(forResource: "barliman-new-test-query-template", ofType: "swift", inDirectory: "mk-and-rel-interp")

        let new_test_query_template_string: String
        do {
            new_test_query_template_string = try String(contentsOfFile: new_test_query_template!)
        } catch {
            print("!!!!!  LOAD_ERROR -- can't load new_test_query_template\n")
            new_test_query_template_string = ""
        }


        // adapted from http://stackoverflow.com/questions/26573332/reading-a-short-text-file-to-a-string-in-swift
        let new_alltests_query_template: String? = bundle.path(forResource: "barliman-new-alltests-query-template", ofType: "swift", inDirectory: "mk-and-rel-interp")

        let new_alltests_query_template_string: String
        do {
            new_alltests_query_template_string = try String(contentsOfFile: new_alltests_query_template!)
        } catch {
            print("!!!!!  LOAD_ERROR -- can't load new_test_query_template\n")
            new_alltests_query_template_string = ""
        }


        let newSimpleQueryString: String
        let newAlltestsQueryString: String




        if let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first {

            let fullSimpleQueryForMondoSchemeFilePath = URL(fileURLWithPath: dir).appendingPathComponent("barliman-query-simple-for-mondo-scheme-file.scm")
            let localSimpleQueryForMondoSchemeFilePath = fullSimpleQueryForMondoSchemeFilePath.path

            let fullNewQueryActualAlltestsFilePath = URL(fileURLWithPath: dir).appendingPathComponent("barliman-new-query-actual-alltests.scm")
            let localNewQueryActualAlltestsFilePath = fullNewQueryActualAlltestsFilePath.path


            let loadFileString =
                    "(define simple-query-for-mondo-file-path \"\(localSimpleQueryForMondoSchemeFilePath)\")"

            newSimpleQueryString = loadFileString + "\n\n" + new_simple_query_template_string

            newAlltestsQueryString =
                    loadFileString + "\n\n" +
                            "(define actual-query-file-path \"\(localNewQueryActualAlltestsFilePath)\")" + "\n\n" +
                            new_alltests_query_template_string
        } else {
            preconditionFailure("Can't find document directory.")
        }

        var pathQuerySimpleForMondoSchemeFile: URL!
        var pathNewSimple: URL!

        var pathNewAlltests: URL!
        var pathNewActualAlltests: URL!




        // write the temporary file containing the query to the user's Document directory.  This seems a bit naughty.  Where is the right place to put this?  In ~/.barliman, perhaps?
        if let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first {

            pathQuerySimpleForMondoSchemeFile = URL(fileURLWithPath: dir).appendingPathComponent(query_simple_for_mondo_scheme_file)


            pathNewSimple = URL(fileURLWithPath: dir).appendingPathComponent(new_query_file_simple)
            pathNewAlltests = URL(fileURLWithPath: dir).appendingPathComponent(new_query_file_alltests)
            pathNewActualAlltests = URL(fileURLWithPath: dir).appendingPathComponent(new_query_file_actual_alltests)

            // write the query files
            do {
                try querySimpleForMondoSchemeContents.write(to: pathQuerySimpleForMondoSchemeFile, atomically: false, encoding: String.Encoding.utf8)
                try newSimpleQueryString.write(to: pathNewSimple, atomically: false, encoding: String.Encoding.utf8)
                try newAlltestsQueryString.write(to: pathNewAlltests, atomically: false, encoding: String.Encoding.utf8)
                try newAlltestsActualQueryString.write(to: pathNewActualAlltests, atomically: false, encoding: String.Encoding.utf8)
            } catch {
                // this error handling could be better!  :)
                print("couldn't write to query files")
            }
        }



        // paths to the Schemes file containing the miniKanren query
        let schemeScriptPathStringNewSimple = pathNewSimple.path
        let schemeScriptPathStringNewAlltests = pathNewAlltests.path




        // create the operations that will be placed in the operation queue
        let runSchemeOpSimple = RunSchemeOperation(codeRunner: self, schemeScriptPathString: schemeScriptPathStringNewSimple, taskType: "simple")
        let runSchemeOpAllTests = RunSchemeOperation(codeRunner: self, schemeScriptPathString: schemeScriptPathStringNewAlltests, taskType: "allTests")


        schemeOperationAllTests = runSchemeOpAllTests


        // wait until the previous operations kill their tasks and finish, before adding the new operations
        //
        // This operation seems expensive.  Barliman seems to work okay without this call.  Need we worry about a race condition here?
        //
        runSchemeOperationQueue.waitUntilAllOperationsAreFinished()


        // now that the previous operations have completed, safe to add the new operations
        runSchemeOperationQueue.addOperation(runSchemeOpAllTests)

        runSchemeOperationQueue.addOperation(runSchemeOpSimple)


        for test in tests {
            if test.shouldProcess {
                let runSchemeTestOperation = buildRunSchemeOperationFor(test: test,
                        withQueryTemplate: new_test_query_template_string, andDefinitionText: definitionText)

                print("queuing \(test.name)")
                runSchemeOperationQueue.addOperation(runSchemeTestOperation)
            }
        }
        
        print("Waiting for finish")
        runSchemeOperationQueue.waitUntilAllOperationsAreFinished()
        return bestGuessInProgress
    }

    func buildRunSchemeOperationFor(test: SchemeTest, withQueryTemplate: String, andDefinitionText: String) -> RunSchemeOperation {
        let testPaths = getTestQueryFilePaths(test: test)
        let newTest1QueryString = getTestQueryString(new_test_query_template_string: withQueryTemplate,
                test: test)
        let newTest1ActualQueryString: String = makeQueryString(andDefinitionText,
                body: test.input,
                expectedOut: test.output,
                simple: false,
                name: "-\(test.name)")

        writeTestQueryFiles(testQuery: newTest1QueryString, testPath: testPaths.testPath, actualTestQuery: newTest1ActualQueryString, actualTestPath: testPaths.actualTestPath)
        let miniKanrenQueryFilePath = testPaths.testPath.path
        let runSchemeOpTest1 = RunSchemeOperation(codeRunner: self, schemeScriptPathString: miniKanrenQueryFilePath, taskType: "\(test.name)", test: test)
        return runSchemeOpTest1
    }

    func getTestQueryString(new_test_query_template_string: String, test: SchemeTest) -> String {
        if let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first {
            let fullSimpleQueryForMondoSchemeFilePath = URL(fileURLWithPath: dir).appendingPathComponent("barliman-query-simple-for-mondo-scheme-file.scm")
            let localSimpleQueryForMondoSchemeFilePath = fullSimpleQueryForMondoSchemeFilePath.path

            let fullNewQueryActualTestFilePath = URL(fileURLWithPath: dir).appendingPathComponent("barliman-new-query-actual-\(test.name).scm")
            let localNewQueryActualTestFilePath = fullNewQueryActualTestFilePath.path


            let loadFileString =
                    "(define simple-query-for-mondo-file-path \"\(localSimpleQueryForMondoSchemeFilePath)\")"

            func makeNewTestNQueryString(_ id: Int, actualQueryFilePath: String) -> String {
                return loadFileString + "\n\n" +
                        "(define actual-query-file-path \"\(actualQueryFilePath)\")" + "\n\n" +
                        "(define (test-query-fn) (query-val-\(test.name)))" + "\n\n\n" +
                        new_test_query_template_string
            }

            return makeNewTestNQueryString(1, actualQueryFilePath: localNewQueryActualTestFilePath)
        } else {
            preconditionFailure("Couldn't find document directory.")
        }
    }

    func getTestQueryFilePaths(test: SchemeTest) -> (testPath: URL, actualTestPath: URL){
        let new_query_file_test = "barliman-new-query-\(test.name).scm"
        let new_query_file_actual_test = "barliman-new-query-actual-\(test.name).scm"

        if let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first {
            return (testPath: URL(fileURLWithPath: dir).appendingPathComponent(new_query_file_test),
                    actualTestPath: URL(fileURLWithPath: dir).appendingPathComponent(new_query_file_actual_test))
        }

        preconditionFailure("Couldn't load files from directory")
    }

    func writeTestQueryFiles(testQuery: String, testPath: URL, actualTestQuery: String, actualTestPath: URL) {
        do {
            try testQuery.write(to: testPath, atomically: false, encoding: String.Encoding.utf8)
            try actualTestQuery.write(to: actualTestPath, atomically: false, encoding: String.Encoding.utf8)
        } catch {
            // this error handling could be better!  :)
            print("couldn't write to query files")
        }
    }


    func makeQuerySimpleForMondoSchemeFileString(_ interp_string: String,
                                                 definitionText: String,
                                                 mk_vicare_path_string: String,
                                                 mk_path_string: String) -> String {

        let load_mk_vicare_string: String = "(load \"\(mk_vicare_path_string)\")"
        let load_mk_string: String = "(load \"\(mk_path_string)\")"

        let querySimple: String = makeQueryString(definitionText,
                body: ",_",
                expectedOut: "q",
                simple: true,
                name: "-simple")


        let full_string: String = load_mk_vicare_string + "\n" +
                load_mk_string + "\n" +
                interp_string + "\n" +
                querySimple

        return full_string
    }

    private func makeAllTestsQueryString(definitionText: String, tests: [SchemeTest]) -> String {
        let allTestInputs = tests.map({$0.input}).joined(separator: " ")
        let allTestOutputs = tests.map({$0.output}).joined(separator: " ")


        // get the path to the application's bundle, so we can load the query string files
        let bundle = Bundle.main

        // adapted from http://stackoverflow.com/questions/26573332/reading-a-short-text-file-to-a-string-in-swift
        let interp_alltests_query_string_part_1: String? = bundle.path(forResource: "interp-alltests-query-string-part-1", ofType: "swift", inDirectory: "mk-and-rel-interp")
        let interp_alltests_query_string_part_2: String? = bundle.path(forResource: "interp-alltests-query-string-part-2", ofType: "swift", inDirectory: "mk-and-rel-interp")

        let alltests_string_part_1: String
        do {
            alltests_string_part_1 = try String(contentsOfFile: interp_alltests_query_string_part_1!)
        } catch {
            print("!!!!!  LOAD_ERROR -- can't load alltests_string_part_1\n")
            alltests_string_part_1 = ""
        }

        let alltests_string_part_2: String
        do {
            alltests_string_part_2 = try String(contentsOfFile: interp_alltests_query_string_part_2!)
        } catch {
            print("!!!!!  LOAD_ERROR -- can't load alltests_string_part_2\n")
            alltests_string_part_2 = ""
        }

        let eval_flags_fast = "(set! allow-incomplete-search? #t)"
        let eval_flags_complete = "(set! allow-incomplete-search? #f)"
        let eval_string_fast = "(begin \(eval_flags_fast) (results))"
        let eval_string_complete = "(begin \(eval_flags_complete) (results))"

        let allTestWriteString = "(define (ans-allTests)\n" +
                "  (define (results)\n" +
                alltests_string_part_1 + "\n" +
                "        (== `( \(definitionText) ) defn-list)" + "\n" + "\n" +
                alltests_string_part_2 + "\n" +
                "(== `(" +
                definitionText +
                ") defns) (appendo defns `(((lambda x x) " +
                allTestInputs +
                ")) begin-body) (evalo `(begin . ,begin-body) (list " +
                allTestOutputs +
                ")" +
                ")))))\n" +
                "(let ((results-fast \(eval_string_fast)))\n" +
                "  (if (null? results-fast)\n" +
                "    \(eval_string_complete)\n" +
                "    results-fast)))"

        let fullString: String = ";; allTests" + "\n" + allTestWriteString

        print("queryAllTests string:\n \(fullString)\n")
        return fullString
    }

    func makeQueryString(_ defns: String,
                         body: String,
                         expectedOut: String,
                         simple: Bool,
                         name: String) -> String {

        let parse_ans_string: String = "(define (parse-ans\(name)) (run 1 (q)" + "\n" +
                " (let ((g1 (gensym \"g1\")) (g2 (gensym \"g2\")) (g3 (gensym \"g3\")) (g4 (gensym \"g4\")) (g5 (gensym \"g5\")) (g6 (gensym \"g6\")) (g7 (gensym \"g7\")) (g8 (gensym \"g8\")) (g9 (gensym \"g9\")) (g10 (gensym \"g10\")) (g11 (gensym \"g11\")) (g12 (gensym \"g12\")) (g13 (gensym \"g13\")) (g14 (gensym \"g14\")) (g15 (gensym \"g15\")) (g16 (gensym \"g16\")) (g17 (gensym \"g17\")) (g18 (gensym \"g18\")) (g19 (gensym \"g19\")) (g20 (gensym \"g20\")))" + "\n" +
                "(fresh (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z _) (parseo `(begin \(defns) \(body)))))))"

        let parse_with_fake_defns_ans_string: String = "(define (parse-ans\(name)) (run 1 (q)" + "\n" +
                " (let ((g1 (gensym \"g1\")) (g2 (gensym \"g2\")) (g3 (gensym \"g3\")) (g4 (gensym \"g4\")) (g5 (gensym \"g5\")) (g6 (gensym \"g6\")) (g7 (gensym \"g7\")) (g8 (gensym \"g8\")) (g9 (gensym \"g9\")) (g10 (gensym \"g10\")) (g11 (gensym \"g11\")) (g12 (gensym \"g12\")) (g13 (gensym \"g13\")) (g14 (gensym \"g14\")) (g15 (gensym \"g15\")) (g16 (gensym \"g16\")) (g17 (gensym \"g17\")) (g18 (gensym \"g18\")) (g19 (gensym \"g19\")) (g20 (gensym \"g20\")))" + "\n" +
                " (fresh (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z _) (fresh (names dummy-expr) (extract-nameso `( \(defns) ) names) (parseo `((lambda ,names \(body)) ,dummy-expr)))))))"


        // get the path to the application's bundle, so we can load the query string files
        let bundle = Bundle.main

        // adapted from http://stackoverflow.com/questions/26573332/reading-a-short-text-file-to-a-string-in-swift
        let interp_eval_query_string_part_1: String? = bundle.path(forResource: "interp-eval-query-string-part-1", ofType: "swift", inDirectory: "mk-and-rel-interp")
        let interp_eval_query_string_part_2: String? = bundle.path(forResource: "interp-eval-query-string-part-2", ofType: "swift", inDirectory: "mk-and-rel-interp")

        let eval_string_part_1: String
        do {
            eval_string_part_1 = try String(contentsOfFile: interp_eval_query_string_part_1!)
        } catch {
            print("!!!!!  LOAD_ERROR -- can't load eval_string_part_1\n")
            eval_string_part_1 = ""
        }

        let eval_string_part_2: String
        do {
            eval_string_part_2 = try String(contentsOfFile: interp_eval_query_string_part_2!)
        } catch {
            print("!!!!!  LOAD_ERROR -- can't load eval_string_part_2\n")
            eval_string_part_2 = ""
        }

        let eval_string = eval_string_part_1 + "\n" +
                "        (== `( \(defns) ) defn-list)" + "\n" +
                eval_string_part_2 + "\n" +
                " (evalo `(begin \(defns) \(body)) \(expectedOut)))))"

        let eval_flags_fast = "(set! allow-incomplete-search? #t)"
        let eval_flags_complete = "(set! allow-incomplete-search? #f)"

        let eval_string_fast = "(begin \(eval_flags_fast) \(eval_string))"
        let eval_string_complete = "(begin \(eval_flags_complete) \(eval_string))"
        let eval_string_both = "(let ((results-fast \(eval_string_fast)))\n" +
                "  (if (null? results-fast)\n" +
                "    \(eval_string_complete)\n" +
                "     results-fast))"

        let define_ans_string: String = "(define (query-val\(name))" + "\n" +
                "  (if (null? (parse-ans\(name)))" + "\n" +
                "      'parse-error" + "\n" +
                "      \(eval_string_both)))"

        let full_string: String = (simple ? ";; simple query" : ";; individual test query") + "\n\n" +
                (simple ? parse_ans_string : parse_with_fake_defns_ans_string) + "\n\n" +
                define_ans_string + "\n\n"

        print("query string:\n \(full_string)\n")

        return full_string
    }
}
