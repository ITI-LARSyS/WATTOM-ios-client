//
//  WattomAnimation.swift
//  iWattom
//
//  Created by Filipe Quintal on 17/07/2019.
//  Copyright © 2019 prsma. All rights reserved.
//

import UIKit
import os.log

/* IMPORTANT ADD @IBDesignable before the class so it easier to see the view in the storyboard,
 I removed it since it consumes a lot of resources in the preview */
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
    
    // tow init methods needed by default, because of the class vars
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
    //when leaves the view kills the thread
    override func willRemoveSubview(_ subview: UIView) {
        self.running=false
    }
    // UIView class that draws
    override func draw(_ rect: CGRect) {
        // Get the Graphics Context
        if let context = UIGraphicsGetCurrentContext() {
            //series of commands to draw the needed objects, the only dynamic part here is the correlation indicator and the target
            // Set the circle outerline-width
            context.setLineWidth(2.5);
            
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
            
            //correlation indicator
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
    // use this UIView method to do some housekeeping since we now the view will be visible and drawn at this stage
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // variables used to better calculate the animation
        self.height = self.frame.height
        self.width  = self.frame.width
        self.middleY = self.height/2
        self.middleX = self.width/2
        self.radious =  self.middleX<self.middleY ? self.middleX-10 : self.middleY-10
        
     
        // thread to animate the view
       let queue = DispatchQueue(label: "work-queue", qos: .userInteractive)
        queue.async {
            self.updateAnimation()
        }
        
        // thread to push the data, we use different threads to assure consistent frequency when pushing the data, that will match the aquisition frequency from the user input
        let queue2 = DispatchQueue(label: "push-queue" , qos: .userInteractive)
        queue2.async {
            self.updateCoordinates()
        }
    }
    // pushes new data into the array, follows the queue ADT
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
    
    // hook for the UIView method that requests a new render for the view
    // used by the animation thread to update the view when new points are calculated
    func updateView(){
        setNeedsDisplay()
    }
    
    func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
    
    func getAnimationCoordinates()-> [CGFloat]{
        return [x,y]
    }
    //getter for the buffer, external classes use this method do access the buffer
    //TODO: might be useful to return a clone of x_buff and y_buff to avoid memory leaks,
    //but i don't know how to properly do it in swift
    func getBuffer() -> Array<[Double]>!{
        let coords:Array<[Double]> = [x_buff,y_buff]
        return coords
    }
    //sets the status of a positive/negative coorelation, used to display the green/red dot
    func setCorrelationStatus(status:Bool){
        self.isCorrelated =  status
    }
    //push the current coords to the array that will be used to coorelate
    func updateCoordinates(){
        while running {
            push(x: Double(x), y: Double(y))
            usleep(UInt32(captureSleep))
        }
    }
    
    func updateAnimation(){
        var refreshViewRate:Int = 0
        while running {
            //new points calculation, every angle bigger than 360 goes back to 0, was getting overflow here :D
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
            if(refreshViewRate==4){  //Although new positions are calculated every "sleep" cycle we only update the view every 4 new positions, to save CPU
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
