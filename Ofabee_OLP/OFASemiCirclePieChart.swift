//
//  OFASemiCirclePieChart.swift
//  Ofabee_OLP
//
//  Created by Administrator on 10/23/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

struct PartialSegment {
    
    // the color of a given segment
    var color: UIColor
    
    // the value of a given segment – will be used to automatically calculate a ratio
    var value: CGFloat
}

class OFASemiCirclePieChart : UIView {
    
    var partialSegments = [PartialSegment]() {
        didSet {
            setNeedsDisplay() // re-draw view when the values get set
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false // when overriding drawRect, you must specify this to maintain transparency.
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {
        
        // get current context
        let ctx = UIGraphicsGetCurrentContext()
        
        // radius is the half the frame's width or height (whichever is smallest)
        let radius = min(frame.size.width, frame.size.height) * 0.5
        
        // center of the view
        let viewCenter = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
        
        // enumerate the total value of the segments by using reduce to sum them
        let valueCount = partialSegments.reduce(0, {$0 + $1.value})
        
        // the starting angle is -90 degrees (top of the circle, as the context is flipped). By default, 0 is the right hand side of the circle, with the positive angle being in an anti-clockwise direction (same as a unit circle in maths).
        var startAngle = 0 / 100 * CGFloat.pi * 2 - CGFloat.pi
        
        for segment in partialSegments { // loop through the values array
            
            // set fill color to the segment color
            ctx?.setFillColor(segment.color.cgColor)
            
            // update the end angle of the segment //endPercent / 100 * CGFloat.pi * 2 - CGFloat.pi
            let endAngle = segment.value / 100 * CGFloat.pi * 2 - CGFloat.pi//startAngle + 2 * .pi * (segment.value / valueCount)
            
            // move to the center of the pie chart
            ctx?.move(to: viewCenter)
            
            // add arc from the center for each segment (anticlockwise is specified for the arc, but as the view flips the context, it will produce a clockwise arc)
            ctx?.addArc(center: viewCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            
            // fill segment
            ctx?.fillPath()
            
            // update starting angle of the next segment to the ending angle of this segment
            startAngle = endAngle
        }
    }
    
//    private func drawSlice(_ rect: CGRect, startPercent: CGFloat, endPercent: CGFloat, color: UIColor) {
//        let center = CGPoint(x: rect.origin.x + rect.width / 2, y: rect.origin.y + rect.height / 2)
//        let radius = min(rect.width, rect.height) / 2
//        let startAngle = startPercent / 100 * CGFloat.pi * 2 - CGFloat.pi
//        let endAngle = endPercent / 100 * CGFloat.pi * 2 - CGFloat.pi
//        let path = UIBezierPath()
//        path.move(to: center)
//        path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
//        path.close()
//        color.setFill()
//        path.fill()
//    }
}
