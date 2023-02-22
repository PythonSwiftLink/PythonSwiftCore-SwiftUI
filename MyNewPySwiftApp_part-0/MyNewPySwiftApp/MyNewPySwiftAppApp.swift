//
//  MyNewPySwiftAppApp.swift
//  MyNewPySwiftApp
//
//  Created by MusicMaker on 07/02/2023.
//

import SwiftUI

@main
struct MyNewPySwiftAppApp: App {
    
    @StateObject var python = PythonHandler.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView(data: .init() )
        }
    }
}
