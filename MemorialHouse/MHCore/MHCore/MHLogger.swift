import OSLog

public enum MHLogger {
    public static func debug<T>(_ object: T?) {
        #if DEBUG
        let message = object != nil ? "[Debug] \(object!)" : "[Debug] nil"
        os_log(.debug, "%@", message)
        #endif
    }
    
    public static func info<T>(_ object: T?) {
        #if DEBUG
        let message = object != nil ? "[Info] \(object!)" : "[Info] nil"
        os_log(.info, "%@", message)
        #endif
    }
    
    public static func error<T>(_ object: T?) {
        #if DEBUG
        let message = object != nil ? "[Error] \(object!)" : "[Error] nil"
        os_log(.error, "%@", message)
        #endif
    }
    
    public static func network<T>(_ object: T?) {
        #if DEBUG
        let message = object != nil ? "[Network] \(object!)" : "[Network] nil"
        os_log(.debug, "%@", message)
        #endif
    }
}
