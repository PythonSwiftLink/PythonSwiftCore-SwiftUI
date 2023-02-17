//
//  main.swift
//  CustomCLI_Swiftonize
//
//  Created by MusicMaker on 17/02/2023.
//

import Foundation
import ArgumentParser
import PythonSwiftLinkParser


@main
struct MyCLI: AsyncParsableCommand {
    init() {
        //        try await checkSwiftTools()
        //        PythonHandler.shared.defaultRunning.toggle()
    }
    
    
    static let configuration = CommandConfiguration(
        abstract: "My CLI",
        version: "0.0",
        subcommands: [Build.self].sorted(by: {$0._commandName < $1._commandName})
    )
    
    
    
    struct Build: AsyncParsableCommand {
        
        //@Argument() var project: String
        @Argument() var source: String
        @Argument() var destination: String
        
        func run() async throws {
            let src = URL(fileURLWithPath: source)
            
            let filename = src.lastPathComponent.replacingOccurrences(of: ".py", with: "")
            
            let dst = URL(fileURLWithPath: destination).appendingPathComponent("\(filename).swift")
            
            let code = try String(contentsOf: src)
            
            let module = await WrapModule(fromAst: filename, string: code, swiftui: false)
            try module.pyswift_code.write(to: dst, atomically: true, encoding: .utf8)
        }
        
    }
    
}
