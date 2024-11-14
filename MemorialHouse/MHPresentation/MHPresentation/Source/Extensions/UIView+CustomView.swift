import UIKit

extension UIView {
    static func dividedLine() -> UIView {
        let line = UIView()
        line.backgroundColor = .dividedLine
        line.setHeight(1)
        
        return line
    }
    
    static func dimmedView(opacity: Float) -> UIView {
        let dim = UIView()
        dim.backgroundColor = .white
        dim.layer.opacity = opacity
        
        return dim
    }
}
