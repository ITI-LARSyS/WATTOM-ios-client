//
//  WattomTouchView.swift
//  iWattom
//
//  Created by Filipe Quintal on 17/07/2019.
//  Copyright © 2019 prsma. All rights reserved.
//

import UIKit



@IBDesignable class WattomTouchView: UIView {
    
    var x:CGFloat = 0.0
    var y:CGFloat = 0.0
    var running = true
    
    var buffer_size:Int = 40
    var currentIndex:Int = 0
    
    var x_buff:[Double]
    var y_buff:[Double]
    
    @IBInspectable var captureSleep:UInt32 = 8000
    
    // nethed init methods
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
    
    // use this UIView method to do some housekeeping since we now the view will be visible and drawn at this stage
    override func didMoveToSuperview() {
        //thread used to push data into the buffer, should have the same aquisition frequency as the push-queue in the wattom animation
        let queue = DispatchQueue(label: "work-queue" , qos: .userInteractive)
        queue.async {
            self.updateTouchCoords()
        }
        super.didMoveToSuperview()
    }
    
    // UIView method that triggers an even whenever a touch is moved, works OK right now but there might be another way to get the XY touch coords
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first?.location(in: self)
        x = location?.x ?? 0
        y = location?.y ?? 0
    }
    
    //returns the lattests coords
    func getTouchCoords()->[CGFloat]{
        return [x,y]
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
    
    //getter for the buffer, external classes use this method do access the buffer
    //TODO: might be useful to return a clone of x_buff and y_buff to avoid memory leaks,
    //but i don't know how to properly do it in swift
    func getBuffer() -> Array<[Double]>!{
        
        let coords:Array<[Double]> = [x_buff,y_buff]
        return coords
    }
    
    //when leaves the view kills the thread
    override func willRemoveSubview(_ subview: UIView) {
        running=false
    }
    
    //function in the thread infinite loop aquiring the user touch coords
    func updateTouchCoords(){
        while running {
            push(x: Double(x), y: Double(y))
            usleep(captureSleep)
        }
    }
}

