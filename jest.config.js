const { jestConfig } = require("@salesforce/sfdx-lwc-jest/config");

module.exports = {
  ...jestConfig,
  collectCoverage: true,
  coverageDirectory: "testresults/jest/coverage",
  coverageReporters: ["clover", "json", "text", "lcov", "cobertura"],
  modulePathIgnorePatterns: ["/.localdevserver"],
  reporters: [
    "default",
    [
      "jest-junit",
      {
        outputDirectory: "testresults/jest/junit",
        outputName: "test-results-lwc.xml"
      }
    ]
  ]
};
