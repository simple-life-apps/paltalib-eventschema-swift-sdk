#!/usr/bin/swift

import Foundation

let rootURL: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).deletingLastPathComponent()

func git(_ command: String...) throws {
    let task = Process()
    
    task.arguments = command
    task.executableURL = URL(fileURLWithPath: "/usr/bin/git")
    task.standardInput = nil
    try task.run()
    task.waitUntilExit()
}

func checkArguments() {
    guard CommandLine.arguments.count == 2 else {
        print("Expected syntax: UpdateCodeVersion.swift <version>")
        exit(1)
    }
}

func updateVersionInLibInfo() throws {
    let code = "let global_sdkVersion = \"\(CommandLine.arguments[1])\""
    
    let url = rootURL
        .appendingPathComponent("Sources")
        .appendingPathComponent("Analytics")
        .appendingPathComponent("AutoUpdatedConstants.swift")
    
    try code.write(to: url, atomically: true, encoding: .utf8)
    try git("add", "../Sources/Analytics/AutoUpdatedConstants.swift")
}

func updatePodspec(_ name: String) throws {
    let url = rootURL.appendingPathComponent("\(name).podspec")
    
    let podspecContents = try String.init(contentsOf: url)
        .components(separatedBy: "\n")
        .map {
            $0.contains("spec.version ") ? patchPodVersionLine($0) : $0
        }
        .joined(separator: "\n")
    
    try podspecContents.write(to: url, atomically: true, encoding: .utf8)
    try git("add", "../\(url.lastPathComponent)")
}

func patchPodVersionLine(_ line: String) -> String {
    let entry = line.components(separatedBy: "=")[0]
    return "\(entry)= \"\(CommandLine.arguments[1])\""
}

func commitChanges() throws {
    try git("commit", "-m", "Automatic version update")
}

checkArguments()
try git("reset")
try updateVersionInLibInfo()
try updatePodspec("PaltaAnalytics")
try updatePodspec("PaltaAnalyticsModel")
try updatePodspec("PaltaAnalyticsPrivateModel")
try updatePodspec("PaltaAnalyticsWiring")
try commitChanges()
