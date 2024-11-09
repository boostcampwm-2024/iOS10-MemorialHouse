import UIKit

extension UIView {
    func setAnchor(
        top: NSLayoutYAxisAnchor? = nil,
        constantTop: CGFloat = 0,
        leading: NSLayoutXAxisAnchor? = nil,
        constantLeading: CGFloat = 0,
        bottom: NSLayoutYAxisAnchor? = nil,
        constantBottom: CGFloat = 0,
        trailing: NSLayoutXAxisAnchor? = nil,
        constantTrailing: CGFloat = 0,
        width: CGFloat? = nil,
        height: CGFloat? = nil
    ) {
        self.translatesAutoresizingMaskIntoConstraints = false
        if let top {
            self.topAnchor.constraint(equalTo: top, constant: constantTop).isActive = true
        }
        
        if let leading {
            self.leadingAnchor.constraint(equalTo: leading, constant: constantLeading).isActive = true
        }
        
        if let bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -constantBottom).isActive = true
        }
        
        if let trailing {
            self.trailingAnchor.constraint(equalTo: trailing, constant: -constantTrailing).isActive = true
        }
        
        if let width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func setTop(anchor: NSLayoutYAxisAnchor, constant: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
    }
    
    func setLeading(anchor: NSLayoutXAxisAnchor, constant: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
    }
    
    func setBottom(anchor: NSLayoutYAxisAnchor, constant: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.bottomAnchor.constraint(equalTo: anchor, constant: -constant).isActive = true
    }
    
    func setTrailing(anchor: NSLayoutXAxisAnchor, constant: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.trailingAnchor.constraint(equalTo: anchor, constant: -constant).isActive = true
    }
    
    func setCenter(view: UIView, offset: CGPoint) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: offset.x).isActive = true
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: offset.y).isActive = true
    }
    
    func setHorizontal(view: UIView, constant: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setLeading(anchor: view.leadingAnchor, constant: constant)
        self.setTrailing(anchor: view.trailingAnchor, constant: constant)
    }
    
    func setHorizontal(layoutGuide: UILayoutGuide, constant: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setLeading(anchor: layoutGuide.leadingAnchor, constant: constant)
        self.setTrailing(anchor: layoutGuide.trailingAnchor, constant: constant)
    }
    
    func setVertical(view: UIView, constant: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTop(anchor: view.topAnchor, constant: constant)
        self.setBottom(anchor: view.bottomAnchor, constant: constant)
    }
    
    func setVertical(layoutGuide: UILayoutGuide, constant: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTop(anchor: layoutGuide.topAnchor, constant: constant)
        self.setBottom(anchor: layoutGuide.bottomAnchor, constant: constant)
    }
    
    func setCenterX(view: UIView, constant: CGFloat = 0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: constant).isActive = true
    }
    
    func setCenterY(view: UIView, constant: CGFloat = 0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
    }
    
    func setWidthAndHeight(width: CGFloat, height: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setHeight(_ height: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setWidth(_ width: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func fillSuperview() {
        self.translatesAutoresizingMaskIntoConstraints = false
        guard let view = self.superview else { return }
        self.setAnchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.trailingAnchor
        )
    }
}
