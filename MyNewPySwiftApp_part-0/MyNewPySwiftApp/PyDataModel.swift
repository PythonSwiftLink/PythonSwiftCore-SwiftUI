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
    // Generic Example
    func callAsFunction<T: PyConvertible, R: ConvertibleFromPython>(method name: String ,_ arg: T) throws -> R {
        let py_name = name.pyPointer
        let v = arg.pyPointer
        let result = PyObject_CallMethodOneArg(self, py_name, v)
        py_name.decref()
        let rtn = try R(object: result)
        result.decref()
        return rtn
    }
    
}

extension PythonObject {
    // Generic Example 
    func callAsFunction<T: PyConvertible, R: ConvertibleFromPython>(_ arg: T) throws -> R {
        let v = arg.pyPointer
        let result = PyObject_CallOneArg(ptr, v)
        let rtn = try R(object: result)
        result.decref()
        return rtn
    }
}


class PyDataModel: ObservableObject {
    @Published var py_string: String = "......."
    @Published var int_value: Int = 0
    
    var get_string: PyPointer
    var get_string2: PyPointer
    var multi_func: PyPointer
    
    var PyClass: PyPointer
    var py_class: PyPointer = nil
    var py_class2: PythonObject?
    
    init() {

        let globals: PyPointer = .globals
        
        // could be from a file also
        let file_url = Bundle.main.url(forResource: "main", withExtension: "py")!
        let code = try! String(contentsOf: file_url)
        
        // returns local dict
        let main_py = PyExec(code: code, globals: globals)
        
        // extract "get_string functions from locals and assign it to internal var "get_string"
        get_string =  main_py["get_string"]
        get_string2 =  main_py["get_string2"]
        multi_func = main_py["multi_func"]
        
        PyClass = main_py["PyClass"]
        // PyPointer = low level
        py_class = PyClass(50)
        // PythonObject = higher level
        py_class2 = .init(
            getter: PyClass(40)
        )
        // garbage collect locals no needed since the custom subscript returned a strong ref to get_string
        main_py.decref()
    }
    
    func py_trigger() {
        let str: PyPointer = get_string()
        let string = try? String(object: str)
        py_string = string ?? "python failed...."
        
    }
    
    func py_trigger2() {
        if let string = try? String(object: get_string2() ) {
            py_string = string
        }        
    }
    
    func py_multi() {
        // wait ... did he just enter swift int value 2 directly as 2nd arg ??
        //... yea but just works as direct entered values
        let result = multi_func(Int.random(in: 0...1000).pyPointer, 2)
        
        if let value = try? Int(object: result ) {
            int_value = value
        }
        result.decref()
    }
    
    func py_class_multi() {
        guard let result = py_class(method: "multi_func", Int.random(in: 0...1000) ).pyPointer else {
            PyErr_Print()
            return
        }
        if let value = try? Int(object: result ) {
            int_value = value
        }
        result.decref()
    }
    
    func py_class_multi_simpler() {
        
        do {
            int_value = try py_class(method: "multi_func", Int.random(in: 0...1000) )
        }
        catch _ {}

    }
    
    func py_class_multi_pythonObject() {
        
        do {
            let py_cls = py_class2!
            int_value = try py_cls.multi_func(Int.random(in: 0...1000) )
        }
        catch _ {}
        
    }
}
