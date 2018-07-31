//
// Created by Ben J on 7/31/18.
// Copyright (c) 2018 Ben Jenkins. All rights reserved.
//

import Foundation

struct TestSuite {
    let definitionText: String
    let tests: [SchemeTest]
}

private let exampleTestSuiteJson =
        """
        {
            "tests": [
                {
                    "id": 1,
                    "input": "(append '(,g1) '(,g2))",
                    "output": "`(,g1 ,g2)"
                },
                {
                    "id": 2,
                    "input": "(append '(,g3 ,g4) '())",
                    "output": "`(,g3 ,g4)"
                }
            ]
        }
        """

class TestLoader {
    static func load(fromJson json: String) -> TestSuite {
        struct LoadableTest: Decodable {
            let input: String
            let output: String
            let id: Int
        }

        struct LoadableTestSuite: Decodable {
            let definition: String
            let tests: [LoadableTest]
        }

        guard let data = Data(base64Encoded: json) else {
            preconditionFailure("Couldnt turn json into data")
        }
        guard let testSuite = try? JSONDecoder().decode(LoadableTestSuite.self, from: data) else {
            preconditionFailure("Error: Couldn't decode json into testsuite")
        }
        return TestSuite(definitionText: testSuite.definition,
                tests: testSuite.tests.map({ SchemeTest(input: $0.input, output: $0.output, id: $0.id) }))

    }
}
