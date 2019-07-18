//
//  WattomTouchView.swift
//  iWattom
//
//  Created by Filipe Quintal on 17/07/2019.
//  Copyright © 2019 prsma. All rights reserved.
//

import UIKit



class WattomTouchView: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    var x:CGFloat = 0.0
    var y:CGFloat = 0.0
    var running = true
    
    var buffer_size:Int = 40
    var currentIndex:Int = 0
    
    var x_buff:[Double]
    var y_buff:[Double]
    
    @IBInspectable var captureSleep:UInt32 = 8000
    
    
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
    
    override func didMoveToSuperview() {
        let queue = DispatchQueue(label: "work-queue")
        queue.async {
            self.updateTouchCoords()
        }
        super.didMoveToSuperview()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first?.location(in: self)
        x = location?.x ?? 0
        y = location?.y ?? 0
        
    }
    
    func getTouchCoords()->[CGFloat]{
        return [x,y]
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
    
    func getBuffer() -> Array<[Double]>!{
        
        let coords:Array<[Double]> = [x_buff,y_buff]
        return coords
    }
    
    override func willRemoveSubview(_ subview: UIView) {
        running=false
    }
    
    func updateTouchCoords(){
        while running {
            push(x: Double(x), y: Double(y))
            usleep(captureSleep)
        }
    }
}

