//
//  ContentView.swift
//  MyNewPySwiftApp
//
//  Created by MusicMaker on 07/02/2023.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var data: PyDataModel
    
    var body: some View {
        VStack(spacing: 32) {
            
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            
            
            
            Text(data.py_string)
                .animation(.easeInOut(duration: 1.0), value: data.py_string)
            
            Button("get_string") {
                data.py_trigger()
            }
            
            Button("get_string2") {
                data.py_trigger2()
            }
            
        }
        .padding(4.0)
        .frame(width: 200.0, height: 400.0)
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var python = PythonHandler.shared
    
    static var previews: some View {
        ContentView(data: .init() )
    }
}
