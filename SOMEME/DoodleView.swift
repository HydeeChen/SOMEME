//
//  DoodleView.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/30.
//

import UIKit

class DoodleView: UIView {
    var lineColor = UIColor.black
    var lineWidth:CGFloat = 10
    var path:UIBezierPath! = UIBezierPath()
    var touchPoint:CGPoint!
    var startingPoint:CGPoint!
    var shapeLayer:CAShapeLayer! = CAShapeLayer()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupShapeLayer()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShapeLayer()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startingPoint = touches.first?.location(in: self)
        path.move(to: startingPoint)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchPoint = touches.first?.location(in: self)
        print("****** touchesMoved:", touchPoint)
        path.addLine(to: touchPoint)  // 移除 path.move(to: startingPoint)
        startingPoint = touchPoint
        draw()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("****** touchesEnded")
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("****** touchesCancelled")
    }
    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        print("****** touchesEstimatedPropertiesUpdated")
    }
    private func setupShapeLayer() {
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(shapeLayer)
    }
    func draw() {
        shapeLayer.path = path.cgPath
        self.setNeedsDisplay()
    }
    func clearCanvas() {
        path.removeAllPoints()
        shapeLayer.path = nil
        self.setNeedsDisplay()
    }
}
