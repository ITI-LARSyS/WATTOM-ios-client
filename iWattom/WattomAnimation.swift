//
//  WattomAnimation.swift
//  iWattom
//
//  Created by Filipe Quintal on 17/07/2019.
//  Copyright © 2019 prsma. All rights reserved.
//

import UIKit
import os.log

// ADD @IBDesignable before the class so it easier to see the view in the storyboard,
// I removed it since it consumes a lot of resources in the preview

class WattomAnimation: UIView {
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    var x:CGFloat = 0
    var y:CGFloat = 0
    var height:CGFloat = 0
    var width:CGFloat  = 0
    var middleX:CGFloat = 0
    var middleY:CGFloat = 0
    var radious:CGFloat = 0
    var running:Bool = true
    // correlation stuff
    var buffer_size:Int = 40
    var currentIndex:Int = 0
    var x_buff:[Double]
    var y_buff:[Double]
    var isCorrelated:Bool = false
    //stuff that shows in the inspector
    @IBInspectable var sartingAngle:CGFloat = 0
    var sleep:UInt32 = 8000
    @IBInspectable var captureSleep:Int = 8000
    @IBInspectable var direction:Int = 1
    @IBInspectable var color:UIColor =  UIColor.red;
    @IBInspectable var rotationSpeed:CGFloat = 1.4 //degrees per seconds
    
    override init(frame: CGRect) {
        x_buff = [Double](repeating: 0, count: buffer_size)
        y_buff = [Double](repeating: 0, count: buffer_size)
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        x_buff = [Double](repeating: 0, count: buffer_size)
        y_buff = [Double](repeating: 0, count: buffer_size)
        super.init(coder: aDecoder)
        // println("  Height "+String(height)+" Width "+String(width))
    }
    
    // let panGestureRecognizer=UIPanGestureRecognizer(target: self, action: #selector(pan))
    // panGestureRecognizer.maximumNumberOfTouches=1
    
    // self.addGestureRecognizer(panGestureRecognizer)
    
    override func willRemoveSubview(_ subview: UIView) {
        self.running=false
    }
    
    override func draw(_ rect: CGRect) {
        // Get the Graphics Context
        if let context = UIGraphicsGetCurrentContext() {
            //print("Drawing again :) ")
            // Set the circle outerline-width
            context.setLineWidth(2.5);
            
            // Set the circle outerline-colour
            
            // Create Circle
            let center = CGPoint(x: self.x, y: self.y)
            let radius:CGFloat = 5.0
            
            // outside ring
            UIColor.gray.set()
            context.addArc(center: CGPoint(x:middleX,y:middleY), radius: self.radious, startAngle: 0.0, endAngle: .pi * 2.0, clockwise: true)
            context.drawPath(using: .stroke)
            
            //target
            color.set()
            context.addArc(center: center, radius: radius, startAngle: 0.0, endAngle: .pi * 2.0, clockwise: true)
            context.drawPath(using: .fillStroke)
            
            //middlepoint
            UIColor.red.set()
            context.addArc(center: CGPoint(x:middleX,y:middleY), radius: radius, startAngle: 0.0, endAngle: .pi * 2.0, clockwise: true)
            context.drawPath(using: .fillStroke)
            
            if(isCorrelated){
                UIColor.green.set()
                context.addArc(center: CGPoint(x:5,y:5), radius: 2, startAngle: 0.0, endAngle: .pi * 2.0, clockwise: true)
                context.drawPath(using: .fillStroke)
            }else{
                UIColor.red.set()
                context.addArc(center: CGPoint(x:5,y:5), radius: 2, startAngle: 0.0, endAngle: .pi * 2.0, clockwise: true)
                context.drawPath(using: .fillStroke)
            }
            
            
        }
    }
    
    /* @objc func pan(panGestureRecognizer:UIPanGestureRecognizer)->Void{
     let currentPoint=panGestureRecognizer.location(in: self)
     let midPoint=self.midPoint(p0: previousPoint, p1: currentPoint)
     
     
     if panGestureRecognizer.state == .began{
     path.move(to: currentPoint)
     }
     else if panGestureRecognizer.state == .changed{
     path.addQuadCurve(to: midPoint,controlPoint: previousPoint)
     }
     
     previousPoint=currentPoint
     self.setNeedsDisplay()
     }*/
    
    /*  func midPoint(p0:CGPoint,p1:CGPoint)->CGPoint{
     let x=(p0.x+p1.x)/2
     let y=(p0.y+p1.y)/2
     return CGPoint(x: x, y: y)
     }*/
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.height = self.frame.height
        self.width  = self.frame.width
        self.middleY = self.height/2
        self.middleX = self.width/2
        self.radious =  self.middleX<self.middleY ? self.middleX-10 : self.middleY-10
        
        /*print(self.height)
        print(self.width)
        print(self.middleX)
        print(self.middleY)
        print(self.radious)*/
       // sleep  = UInt32(round((rotationSpeed*1000000)/360))
       // print("will sleep for "+String(sleep))
        
       let queue = DispatchQueue(label: "work-queue", qos: .userInteractive)
        queue.async {
            self.updateAnimation()
        }
        
        let queue2 = DispatchQueue(label: "push-queue" , qos: .userInteractive)
        queue2.async {
            self.updateCoordinates()
        }
    }
    
    func push(x:Double, y:Double){
        
        if(currentIndex < buffer_size){
            x_buff[currentIndex]=x
            y_buff[currentIndex]=y
            currentIndex+=1
        }else{
            
            for index in stride(from:buffer_size-1, to:0, by:-1){
                x_buff[index] = x_buff[index-1]
                y_buff[index] = y_buff[index-1]
            }
            x_buff[0] = x
            y_buff[0] = y
        }
    }
    
    func updateView(){
        setNeedsDisplay()
    }
    
    func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
    
    
    
    func getAnimationCoordinates()-> [CGFloat]{
        return [x,y]
    }
    
    func getBuffer() -> Array<[Double]>!{
        let coords:Array<[Double]> = [x_buff,y_buff]
        return coords
    }
    
    func setCorrelationStatus(status:Bool){
        self.isCorrelated =  status
    }
    
    func updateCoordinates(){
        while running {
            push(x: Double(x), y: Double(y))
            usleep(UInt32(captureSleep))
            //print(captureSleep)
            //print(x)
            //print(y)
        }
    }
    
    func updateAnimation(){
        var refreshViewRate:Int = 0
        while running {
            x = radious*CGFloat(cos(deg2rad(Double(sartingAngle))))+middleX
            y = radious*CGFloat(sin(deg2rad(Double(sartingAngle))))+middleY
            if(sartingAngle>=360){
                sartingAngle = 0
            }
            sartingAngle = sartingAngle+CGFloat(self.direction*1)
            sleep = UInt32(round((rotationSpeed*1000000)/360))
            usleep(sleep)
            //print(sleep)
            // print(y)
            if(refreshViewRate==4){
                DispatchQueue.main.async {
                    self.updateView()
                    }
                    refreshViewRate=0
            }else{
                refreshViewRate+=1
            }
        }
    }
}
