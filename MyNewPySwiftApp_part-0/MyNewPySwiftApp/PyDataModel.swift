//
//  PyDataModel.swift
//  MyNewPySwiftApp
//
//  Created by MusicMaker on 09/02/2023.
//

import Foundation
import PythonLib
import PythonSwiftCore
import Combine


fileprivate func PyExec(code: String, globals: PyPointer) -> PyPointer {
    
    let locals = PyDict_New()
    
    if let result = PyRun_String(string: code, flag: .file, globals: globals, locals: locals) {
        Py_DecRef(result)
    }
    
    return locals
}

fileprivate extension PyPointer {
    static var pyDict_New: PyPointer { PyDict_New() }
    
    static var globals: PyPointer {
        let handler = PythonHandler.shared
        
        if let g = handler.globals {
            return g
        }
        
        return .PyNone
    }
    
    subscript(key: String) -> PyPointer {
        get {
            PyDict_GetItem(self, key).xINCREF
        }
        set {
            PyDict_SetItem(self, key, newValue)
        }
    }
    
    
}


class PyDataModel: ObservableObject {
    @Published var py_string: String
    
    
    var get_string: PyPointer
    var get_string2: PyPointer
    
    init() {
        
        py_string = "......."
        
        let globals: PyPointer = .globals
        
        // could be from a file also
        let code = """
        
        def get_string() -> str:
            return "hello from python"
        
        def get_string2() -> str:
            return "another string from python"
        
        """
        
        // returns local dict
        let new_functions = PyExec(code: code, globals: globals)
        
        // extract "get_string functions from locals and assign it to internal var "get_string"
        get_string =  new_functions["get_string"]
        get_string2 =  new_functions["get_string2"]
        
        // garbage collect locals no needed since the custom subscript returned a strong ref to get_string
        new_functions.decref()
    }
    
    func py_trigger() {
        let str: PyPointer = get_string()
        let string = try? String(object: str)
        py_string = string ?? "python failed...."
        
    }
    
    func py_trigger2() {
        let str: PyPointer = get_string2()
        let string = try? String(object: str)
        py_string = string ?? "python failed...."
        
    }
    
}
