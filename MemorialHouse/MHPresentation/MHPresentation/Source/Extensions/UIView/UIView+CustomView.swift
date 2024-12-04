import UIKit

extension UIView {
    static func dividedLine() -> UIView {
        let dividedLineView = UIView()
        dividedLineView.backgroundColor = .dividedLine
        dividedLineView.setHeight(1)
        
        return dividedLineView
    }
    
    static func dimmedView(opacity: Float, color: UIColor = .white) -> UIView {
        let dimmedView = UIView()
        dimmedView.backgroundColor = color
        dimmedView.layer.opacity = opacity
        dimmedView.isUserInteractionEnabled = false
        
        return dimmedView
    }
}
