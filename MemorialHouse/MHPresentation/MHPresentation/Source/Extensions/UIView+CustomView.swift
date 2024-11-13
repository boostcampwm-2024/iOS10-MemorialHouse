import UIKit

extension UIView {
    static func dividedLine() -> UIView {
        let line = UIView()
        line.backgroundColor = .dividedLine
        line.setHeight(1)
        
        return line
    }
    
    static func dimmedView(opacity: Float, color: UIColor = .white) -> UIView {
        let dim = UIView()
        dim.backgroundColor = color
        dim.layer.opacity = opacity
        dim.isUserInteractionEnabled = false
        
        return dim
    }
}
