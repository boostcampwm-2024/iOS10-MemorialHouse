import OSLog

public enum MHLogger {
    static func debug<T>(_ object: T?) {
        #if DEBUG
        let message = object != nil ? "\(object!)" : "nil"
        os_log(.debug, "%@", message)
        #endif
    }
    
    static func info<T>(_ object: T?) {
        #if DEBUG
        let message = object != nil ? "\(object!)" : "nil"
        os_log(.info, "%@", message)
        #endif
    }
    
    static func error<T>(_ object: T?) {
        #if DEBUG
        let message = object != nil ? "\(object!)" : "nil"
        os_log(.error, "%@", message)
        #endif
    }
    
    static func network<T>(_ object: T?) {
        #if DEBUG
        let message = object != nil ? "\(object!)" : "nil"
        os_log(.debug, "Network Log: %@", message)
        #endif
    }
}
