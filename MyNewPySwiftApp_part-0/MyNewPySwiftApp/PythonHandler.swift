//
//  PythonHandler.swift
//  touchBay editor
//
//  Created by MusicMaker on 04/11/2022.
//

import Foundation
import PythonLib
import PythonSwiftCore
import Combine

class PythonHandler: ObservableObject {
    
    static let shared = PythonHandler()
    var threadState: UnsafeMutablePointer<PyThreadState>?
    
    var python_module: PyPointer
    var globals: PyPointer
    var err_io: PythonObject?
    
    var extra_modules: [String:PyPointer] = [:]
    
    var builtins: PyPointer
    //var stderr: PyObject
    init() {
        let resourcePath = Bundle.main.resourcePath!
        print(try! FileManager.default.contentsOfDirectory(atPath: resourcePath))
        var config: PyConfig = .init()
        print("Configuring isolated Python...")
        PyConfig_InitIsolatedConfig(&config)
        
        // Configure the Python interpreter:
        // Run at optimization level 1
        // (remove assertions, set __debug__ to False)
        config.optimization_level = 1
        // Don't buffer stdio. We want output to appears in the log immediately
        config.buffered_stdio = 0
        // Don't write bytecode; we can't modify the app bundle
        // after it has been signed.
        config.write_bytecode = 0
        // Isolated apps need to set the full PYTHONPATH manually.
        config.module_search_paths_set = 1
        
        var status: PyStatus
        
        let python_home = "\(resourcePath)/Support/Python/Resources"
        
        var wtmp_str = Py_DecodeLocale(python_home, nil)
        
        var config_home: UnsafeMutablePointer<wchar_t>!// = config.home
        
        status = PyConfig_SetString(&config, &config_home, wtmp_str)
        
        PyMem_RawFree(wtmp_str)
        
        config.home = config_home
        
        status = PyConfig_Read(&config)
        
        print("PYTHONPATH:")
        
        let path = "\(resourcePath)/Support/Python/Resources/lib/python3.10"
        //let path = "\(resourcePath)/"

        print("- \(path)")
        wtmp_str = Py_DecodeLocale(path, nil)
        status = PyWideStringList_Append(&config.module_search_paths, wtmp_str)
        
        PyMem_RawFree(wtmp_str)
        
        
        //PyImport_AppendInittab(makeCString(from: "midi_utils"), PyInit_midi_utils)
        
        //PyErr_Print()
        
        //let new_obj = NewPyObject(name: "fib", cls: Int.self, _methods: FibMethods)
        print("Initializing Python runtime...")
        status = Py_InitializeFromConfig(&config)
        
        //let _ = PyWidgetDataType
        //let _ = PyWidgetLabelType
        let StringIO: PyPointer = pythonImport(from: "io", import_name: "StringIO")
        let timeit: PyPointer = pythonImport(from: "timeit", import_name: "timeit")
        
        err_io = .init(ptr: StringIO(), from_getter: true)
        python_module = PyImport_AddModule("__main__")
        
        
//        let midi_utils = PyImport_ImportModule("midi_utils")
//        if midi_utils == nil {
//            fatalError()
//        }
        
        globals = PyModule_GetDict(python_module)
        
        
        
        
        builtins = PyEval_GetBuiltins()
        //PySys_SetObject("stderr", err_io?.ptr)
        PyModule_AddObject(python_module, "timeit", timeit)
        //PyDict_SetItemString(globals, "fib_cls", o_ptr)
        //PyModule_AddFunctions(python_module, GlobalPyMethods.methods_ptr)
        let pythonPrint = PyDict_GetItemString(builtins, "print")
        
        //PythonHandlerInjector(python_module: python_module)
        //let midi_utils_dict = PyModule_GetDict(midi_utils)
        
        //midi_utils_dict.decref()
        //        let string = """
        //        for x in range(2_000_000):
        //            cc_out(0,0,0,x % 128)
        //        """
        //        PyRun_String(string, Py_file_input, globals, globals)
    }
}

let python_handler = PythonHandler.shared

//let builtins = PyEval_GetBuiltins()
public let pythonPrint = PyDict_GetItemString(python_handler.builtins, "print")
public let pyPrint = pythonPrint
public let pythonDir = PyDict_GetItemString(python_handler.builtins, "print")
//let python_module = PyImport_AddModule("__main__")
//var err_io: PythonObject? = nil
//let globals = PyModule_GetDict(python_module)
