import UIKit

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        /// 회전된 이미지의 새로운 이미지 크기 계산
        var newSize = CGRect(
            origin: CGPoint.zero,
            size: self.size
        ).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        
        /// Core Graphics가 반올림으로 인한 오차를 발생시키지 않도록 소수점 이하 버림
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        /// 위에서 설정한 새로운 크기의 GraphicContext 생성
        /// false: 배경을 투명하게 설정
        /// self.scale: 원본 이미지의 해상도 유지
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        /// Context의 원점을 이미지 중앙으로 이동
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        /// 중심점을 기준으로 이미지 회전
        context.rotate(by: CGFloat(radians))
        /// 회전된 context에 그림 그리기
        /// 이때, 중앙을 기준으로 그리기 위해 x, y좌표를 넓이, 높이의 절반 음수 값을 넣어줌
        self.draw(in: CGRect(
                x: -self.size.width/2,
                y: -self.size.height/2,
                width: self.size.width,
                height: self.size.height))
    
        /// 회전된 이미지를 새로운 UIImage로 생성 후 GraphicContext 종료
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
