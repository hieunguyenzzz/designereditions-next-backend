const { loadEnv } = require("@medusajs/utils");
loadEnv("test", process.cwd());

/** @type {import('ts-jest').JestConfigWithTsJest} */
module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",
  moduleFileExtensions: ["js", "json", "ts"],
  rootDir: "src",
  testRegex: ".*\\.test\\.ts$",
  transform: {
    "^.+\\.(t|j)s$": "ts-jest"
  },
  collectCoverageFrom: [
    "**/*.(t|j)s"
  ],
  coverageDirectory: "../coverage",
  // Add these for Medusa compatibility
  moduleNameMapper: {
    "^@medusajs/medusa/dist/(.*)": "@medusajs/medusa/dist/$1",
    "^@medusajs/medusa$": "@medusajs/medusa/dist",
    "^@medusajs/framework/dist/(.*)": "@medusajs/framework/dist/$1"
  }
};

if (process.env.TEST_TYPE === "integration:http") {
  module.exports.testMatch = ["**/integration-tests/http/*.spec.[jt]s"];
} else if (process.env.TEST_TYPE === "integration:modules") {
  module.exports.testMatch = ["**/src/modules/*/__tests__/**/*.[jt]s"];
} else if (process.env.TEST_TYPE === "unit") {
  module.exports.testMatch = ["**/src/**/__tests__/**/*.unit.spec.[jt]s"];
}
