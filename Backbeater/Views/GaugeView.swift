//
//  GaugeView.swift
//  Backbeater
//
//  Created by Alejandro (idev) on 6/5/19.
//

import UIKit

class GaugeView: UIView {

    var outerBezelColor = ColorPalette.pink.color
    var outerBezelWidth: CGFloat = 6
    
    var innerBezelColor = ColorPalette.black.color
    var innerBezelWidth : CGFloat = 1
    
    var insideColor = ColorPalette.black.color
    
    var segmentWidth : CGFloat = 20
//    var segmentColors = [UIColor(red: 0.7, green: 0, blue: 0, alpha: 1),
//                         UIColor(red: 0, green: 0.5, blue: 0, alpha: 1),
//                         UIColor(red: 0, green: 0.5, blue: 0, alpha: 1),
//                         UIColor(red: 0, green: 0.5, blue: 0, alpha: 1),
//                         UIColor(red: 0.7, green: 0, blue: 0, alpha: 1)]
    var segmentColors = [ColorPalette.black.color,
                         ColorPalette.black.color,
                         ColorPalette.black.color,
                         ColorPalette.black.color,
                         ColorPalette.black.color,
                         ColorPalette.black.color,
                         ColorPalette.black.color,
                         ColorPalette.black.color]

    var dotStrings = [4, 3, 2, 1, 0, 1, 2, 3, 4]
    
    var totalAngle: CGFloat = 180
    var rotation: CGFloat = -90
    
    var majorTickColor = UIColor.white
    var majorTickWidth : CGFloat = 2
    var majorTickLength : CGFloat = 30
    
    var minorTickColor = UIColor.white
    var minorTickWidth : CGFloat = 1
    var minorTickLength : CGFloat = 20
    var minorTickCount = 3
    
    var outerCenterDiscColor = UIColor(white: 0.9, alpha: 1)
    var outerCenterDiscWidth : CGFloat = 35
    var innerCenterDiscColor = UIColor(white: 0.7, alpha: 1)
    var innterCenterDiscWidth : CGFloat = 25
    
    var needColor = UIColor(white: 0.7, alpha: 1)
    var needleWidth : CGFloat = 4
    let needle = UIView()
    
    let range = Tempo.max - Tempo.min
    var offsetY: CGFloat = 0
    var needleAngle: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    var bpm: Float = 0 {
        didSet {
            //figure out where the needle is, between 0 and 1
            var v = bpm
            if bpm < 0 { v = 0 }
            else if bpm > 1 { v = 1 }
            
            //lerp from the start to end position, based on the needle's position
            let needleRotation = rotation + totalAngle * CGFloat(v)
            let angle = self.deg2rad(needleRotation)
            
            if needleAngle != needleRotation {
//                print("needle = \(needleAngle), current = \(needleRotation)")
                if needleAngle == 90.0 && needleRotation == -90.0 {
                    UIView.animate(withDuration: 0.15, animations: {
                        self.needle.transform = CGAffineTransform(rotationAngle: 0)
                    }) { (comp) in
                        UIView.animate(withDuration: 0.15, animations: {
                            self.needle.transform = CGAffineTransform(rotationAngle: angle)
                        })
                    }
                }
                else {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.needle.transform = CGAffineTransform(rotationAngle: angle)
                    })
                }
                needleAngle = needleRotation
            }
        }
    }
    
    var tempo: Int = 0
    /*{
        didSet {
            if let label = self.viewWithTag(10 + dotStrings.count/2) as? UILabel {
//                label.text = "\(tempo)"
            }
        }
    }
    */
    func drawBackground(in rect: CGRect, context ctx: CGContext){
        ctx.saveGState()
        //draw the outer bezel as the largest circle
        var outerRect = rect
        outerRect.origin.y += offsetY
        var radius = rect.width
        if radius > 540 {
            radius = 540
            outerRect = outerRect.insetBy(dx: (rect.width - 540)/2, dy: (rect.height-540)/2)
        }
        if UIScreen.main.bounds.width <= 375 {
            outerBezelWidth = 4
            radius -= 16
            outerRect = outerRect.insetBy(dx: (rect.width - radius)/2, dy: (rect.height-radius)/2)
        }
        outerBezelColor.set()
        ctx.fillEllipse(in: outerRect)
        
        //move in a little on each edge, then draw the inner bezel
        let innerBezelRect = outerRect.insetBy(dx: outerBezelWidth, dy: outerBezelWidth)
        innerBezelColor.set()
        ctx.fillEllipse(in: innerBezelRect)
        
        //finally, move in some more and draw the inside of our gauge
        let insideRect = innerBezelRect.insetBy(dx: innerBezelWidth, dy: innerBezelWidth)
        insideColor.set()
        ctx.fillEllipse(in: insideRect)
        
        let halfRect = CGRect(x: 0, y: offsetY + rect.height*0.5+2, width: rect.width, height: rect.height*0.5)
        insideColor.set()
        ctx.fill(halfRect)
        
        let edgeRect = CGRect(x: outerRect.origin.x, y: outerRect.origin.y + outerRect.height*0.5-2, width: 6, height: 6)
        outerBezelColor.set()
        ctx.fillEllipse(in: edgeRect)
        
        let edgeRect2 = CGRect(x: outerRect.origin.x + outerRect.width-6, y: outerRect.origin.y + outerRect.height*0.5-2, width: 6, height: 6)
        outerBezelColor.set()
        ctx.fillEllipse(in: edgeRect2)
        ctx.restoreGState()
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return}
        drawBackground(in: rect, context: ctx)
//        drawSegments(in: rect, context: ctx)
        drawTicks(in: rect, context: ctx)
        drawCenterDisc(in: rect, context: ctx)
    }
    
    //1. Save the current configuration of our drawing context. We're about to make changes, and we dont want to pollute what comes next
    //2. Move our drawing context into the center of our draw rectangle, then rotate it so we're pointing toward the start of the first segment. Moving
    //  like this means we will draw relative to the center of our rectangle, which make rotations more natural
    //3. Tell Core Graphics that we want to draw arcs using the size specified in our segmentWidth property
    //4. Calculate the size fo each segment by dividing the total angle of our gauge by the number of segments
    //5. Calculate the radius of our segment arc. This should be equal to the width of the draw rectangle minus our segment width, then halved. We halve the rectangle width we want radius not diameter, and we halve the segment width because Core Graphics draw half the line over the radius and half under, we want it all under. Finally, we take away the outer and inner bezel widths.
    //6. Loop over each segment color, drawing one piece of the arc at a time
    //7. Reset the graphics state to its earlier configuration
    func drawSegments(in rect: CGRect, context ctx: CGContext){
        //1: Save the current drawing configuration
        ctx.saveGState()
        
        //2: Move to the center of our drawing rectangle and rotate so that we're pointing at the start of the first segment
        ctx.translateBy(x: rect.midX, y: rect.midY)
        ctx.rotate(by: deg2rad(rotation) - (.pi / 2)) // we need to subtrace .pi / 2 from the rotation because Core Graphics measures its angles where zero degress is directly to the right.
        
        //3: Set up  the user's line width
        ctx.setLineWidth(segmentWidth)
        
        //4: Calculate the size of each segment in the total guage
        let segmentAngle = deg2rad(totalAngle / CGFloat(segmentColors.count))
        var radius = rect.width
        if radius > 540 {
            radius = 540
        }
        if UIScreen.main.bounds.width <= 375 {
            radius -= 16
        }
        //5: Calculate how wide the segment arcs shouls be
        let segmentRadius = (((radius - segmentWidth) / 2) - outerBezelWidth) - innerBezelWidth
        
        //6: Draw each segment
        for(index, segment) in segmentColors.enumerated() {
            //figure out where the segment starts in our arc
            let start = CGFloat(index) * segmentAngle
            
            //active its color
            segment.set()
            
            //add a path for the segment
            ctx.addArc(center: .zero, radius: segmentRadius, startAngle: start, endAngle: start + segmentAngle, clockwise: false)
            
            // and stroke it using the activate color
            ctx.drawPath(using: .stroke)
        }
        
        // 7: reset the graphics state
        ctx.restoreGState()
    }

    func drawTicks (in rect: CGRect, context ctx: CGContext){
        //save our clean graphics state
        ctx.saveGState()
        ctx.translateBy(x: rect.midX, y: rect.midY + offsetY)
        ctx.rotate(by: deg2rad(rotation) - (.pi / 2))
        
        let segmentAngle = deg2rad(totalAngle / CGFloat(segmentColors.count))
        var radius = rect.width
        if radius > 540 {
            radius = 540
        }
        if UIScreen.main.bounds.width <= 375 {
            radius -= 16
            majorTickLength = 26
            if UIScreen.main.bounds.width == 320 {
                majorTickLength = 24
            }
        }
        let segmentRadius = (((radius - segmentWidth) / 2) - outerBezelWidth) - innerBezelWidth
        
        //save the graphics state where we've moved to the center and rotated towards the start fo the first segment
        ctx.saveGState()
        
        //draw major ticks
        
//        ctx.setLineWidth(majorTickWidth)
        
        majorTickColor.set()
        let majorEnd = segmentRadius + (segmentWidth / 2)
        let majorStart = majorEnd - majorTickLength
        
        for _ in 0 ... segmentColors.count {
            ctx.setLineWidth(majorTickWidth)
            ctx.setLineCap(.round)
            ctx.move(to: CGPoint(x: majorStart, y: 0))
            ctx.addLine(to: CGPoint(x: majorEnd, y: 0))
            ctx.drawPath(using: .stroke)
            ctx.rotate(by: segmentAngle)
        }
        
        //go back to the state we had before we drew the major ticks
        ctx.restoreGState()
//        //save it again, because we're about to draw the minor ticks
//        ctx.saveGState()
//
//        //draw minor ticks
//        ctx.setLineWidth(minorTickWidth)
//        minorTickColor.set()
//        let minorEnd = segmentRadius + (segmentWidth / 2)
//        let minorStart = minorEnd - minorTickLength
//
//        let minorTickSize = segmentAngle / CGFloat(minorTickCount + 1) // The “plus one” part is important, because we draw the ticks inside the segments rather than at the ages. For example, if we had a segment angle of 100 and wanted three ticks, dividing 100 by three would place ticks at 33, 66, and 99 – there would be a tick right next to the major tick line at 100.
//        for _ in 0 ..< segmentColors.count {
//            ctx.rotate(by: minorTickSize)
//
//            for _ in 0 ..< minorTickCount{
//                ctx.move(to: CGPoint(x: minorStart, y: 0))
//                ctx.addLine(to: CGPoint(x: minorEnd, y: 0))
//                ctx.drawPath(using: .stroke)
//                ctx.rotate(by: minorTickSize)
//            }
//        }
//
//        // go back to the graphics state where we've moved to the center and rotated towards the start of the first segement
//        ctx.restoreGState()
        //go back to the original graphics state
        ctx.restoreGState()
    }
    
    func drawCenterDisc(in rect: CGRect, context ctx: CGContext){
        ctx.saveGState()
        ctx.translateBy(x: rect.midX, y: rect.midY + offsetY)
        
        let outerCenterRect = CGRect(x: -outerCenterDiscWidth / 2, y: -outerCenterDiscWidth / 2, width: outerCenterDiscWidth, height: outerCenterDiscWidth)
        outerCenterDiscColor.set()
        ctx.fillEllipse(in: outerCenterRect)
        
        let innerCenterRect = CGRect(x: -innterCenterDiscWidth / 2, y: -innterCenterDiscWidth / 2, width: innterCenterDiscWidth, height: innterCenterDiscWidth)
        innerCenterDiscColor.set()
        ctx.fillEllipse(in: innerCenterRect)
        
        ctx.restoreGState()
    }
    
    func setUp() {
        let winSize = UIScreen.main.bounds.size
        if (winSize.height / winSize.width) < 2 {
            offsetY = 40
            if winSize.width <= 320 || winSize.width >= 768 {
                offsetY = 80
            }
            else if winSize.width <= 375 {
                offsetY = 60
            }
        }
        DispatchQueue.main.async {
            var fontSize:CGFloat
            switch ScreenUtil.screenSizeClass {
                case .xsmall: fontSize = 8
                case .small:  fontSize = 10
                case .medium: fontSize = 14
                case .large:  fontSize = 16
                case .xlarge: fontSize = 18
            }
            
            let font10 = Font.FuturaDemi.get(fontSize)
            
            let rect = self.bounds
            let center = CGPoint(x: rect.midX, y: rect.midY + self.offsetY)
            
            var radius = rect.width
            if radius > 540 {
                radius = 540
            }
            
            let segmentRadius = (((radius - self.segmentWidth) / 2) - self.outerBezelWidth) - self.innerBezelWidth - self.segmentWidth - 16
            
            let slowLabel = UILabel()
            slowLabel.backgroundColor = UIColor.clear
            slowLabel.font = font10
            slowLabel.tag = 0 + 10
            slowLabel.text =  "SLOW"
            slowLabel.textAlignment = .right
            slowLabel.textColor = .white
            slowLabel.frame = CGRect(x: center.x - segmentRadius - 22, y: center.y - 12, width: 50, height: 24)
            
            self.addSubview(slowLabel)
            
            let fastLabel = UILabel()
            fastLabel.backgroundColor = UIColor.clear
            fastLabel.font = font10
            fastLabel.tag = 8 + 10
            fastLabel.text =  "FAST"
            fastLabel.textAlignment = .left
            fastLabel.textColor = .white
            fastLabel.frame = CGRect(x: center.x + segmentRadius - 22, y: center.y - 12, width: 50, height: 24)
            
            self.addSubview(fastLabel)
            
            let needle = self.needle
            needle.backgroundColor = self.needColor
            needle.translatesAutoresizingMaskIntoConstraints = false
            
            //make the needle a third of our height
            needle.bounds = CGRect(x: 0, y: 0, width: self.needleWidth, height: radius / 3 )
            
            // align it so that it is positioned and rotated from the bottom center
            needle.layer.anchorPoint = CGPoint(x:0.5, y:1)
            needle.layer.cornerRadius = self.needleWidth / 2
            
            // now center the needle over our center point
            needle.center = center
            self.addSubview(needle)
        }
    }
    
    func deg2rad(_ number: CGFloat) -> CGFloat {
        return number * .pi / 180
    }
    
}
