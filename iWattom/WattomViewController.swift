//
//  WattomViewController.swift
//  iWattom
//
//  Created by Filipe Quintal on 17/07/2019.
//  Copyright © 2019 prsma. All rights reserved.
//

import UIKit

class WattomViewController: UIViewController {
    
    

    @IBOutlet weak var wattomTouch: WattomTouchView!
    @IBOutlet weak var wattom1: WattomAnimation!
    @IBOutlet weak var wattom2: WattomAnimation!
    @IBOutlet weak var wattom3: WattomAnimation!
    @IBOutlet weak var wattom4: WattomAnimation!
    @IBOutlet weak var wattom5: WattomAnimation!
    @IBOutlet weak var wattom6: WattomAnimation!
    
    var correlationRunning:Bool =  true;
    var correelationFreq:UInt32 =  300000
    var x_touchBuffer:[CGFloat]
    var y_touchBuffer:[CGFloat]
    
   // var buffer_size:Int = 40
   // var currentIndex:Int = 0
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        x_touchBuffer = []
        y_touchBuffer = []
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
       // fatalError("init(coder:) has not been implemented")
        x_touchBuffer = []
        y_touchBuffer = []
        super.init(coder:aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let queue = DispatchQueue(label: "work-queue")
        queue.async {
            self.calculateCorreation()
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.correlationRunning=false
        super.viewWillDisappear(animated)
        
    }
    
    func pearson(x: [Double], y: [Double]) -> Double? {
        if let cov = Sigma.covariancePopulation(x: x, y: y),
            let σx = Sigma.standardDeviationPopulation(x),
            let σy = Sigma.standardDeviationPopulation(y) {
            
            if σx == 0 || σy == 0 { return nil }
            
            return cov / (σx * σy)
        }
        
        return nil
    }
    
    /*func push(x:Double, y:Double){
        
        if(currentIndex < buffer_size){
            x_buff[currentIndex]=x
            y_buff[currentIndex]=y
            currentIndex+=1
        }else{
            for index in 0...buffer_size-2{
                x_buff[index+1] = x_buff[index]
                y_buff[index+1] = y_buff[index]
            }
            x_buff[currentIndex] = x
            y_buff[currentIndex] = y
            //currentIndex+=1
        }
    }
    
    func calculateCorreation(){
        
        sleep(4)
        var x_c_buff:[Double]  = [Double](repeating: 0, count: 40)
        var y_c_buff:[Double]  = [Double](repeating: 0, count: 40)
        var x_t_buff:[Double]  = [Double](repeating: 0, count: 40)
        var y_t_buff:[Double]  = [Double](repeating: 0, count: 40)
        
        while(correlationRunning){
            print("---- Calculating coorelation ---")
            //let test1:[Double] =  wattom1.getBuffer()[0]
            print(pearson(x:wattom1.getBuffer()[0], y:wattomTouch.getBuffer()[0]))
            print(pearson(x:wattom1.getBuffer()[1], y:wattomTouch.getBuffer()[1]))
            
            sleep(1)
        }
    }*/
    
    
    func calculateCorreation(){
        
        sleep(4)
        var touch:Array<[Double]>
        var corr1:Double
        var corr2:Double
        while(correlationRunning){
            //print("---- Calculating coorelation ---")
            //let test1:[Double] =  wattom1.getBuffer()[0]
            //print(wattom1.getBuffer()[0])
            //print("#")
            //print( wattomTouch.getBuffer()[0])
            touch = wattomTouch.getBuffer()
            corr1 = (pearson(x:wattom1.getBuffer()[0], y:touch[0])) ?? 0
            corr2 = (pearson(x:wattom1.getBuffer()[1], y:touch[1])) ?? 0
            if(corr1>0.85 && corr2>0.85){
                print("positive corr 1")
                wattom1.setCorrelationStatus(status: true)
            }else{
                wattom1.setCorrelationStatus(status: false)
            }
            
            
            corr1 = (pearson(x:wattom2.getBuffer()[0], y:touch[0])) ?? 0
            corr2 = (pearson(x:wattom2.getBuffer()[1], y:touch[1])) ?? 0
            if(corr1>0.85 && corr2>0.85){
                print("positive corr 2")
                wattom2.setCorrelationStatus(status: true)
            }else{
                wattom2.setCorrelationStatus(status: false)
            }
            
            corr1 = (pearson(x:wattom3.getBuffer()[0], y:touch[0])) ?? 0
            corr2 = (pearson(x:wattom3.getBuffer()[1], y:touch[1])) ?? 0
            if(corr1>0.85 && corr2>0.85){
                print("positive corr 3")
                wattom3.setCorrelationStatus(status: true)
            }else{
                wattom3.setCorrelationStatus(status: false)
            }
            
            corr1 = (pearson(x:wattom4.getBuffer()[0], y:touch[0])) ?? 0
            corr2 = (pearson(x:wattom4.getBuffer()[1], y:touch[1])) ?? 0
            if(corr1>0.85 && corr2>0.85){
                print("positive corr 4")
                wattom4.setCorrelationStatus(status: true)
            }else{
                wattom4.setCorrelationStatus(status: false)
            }
            
            corr1 = (pearson(x:wattom5.getBuffer()[0], y:touch[0])) ?? 0
            corr2 = (pearson(x:wattom5.getBuffer()[1], y:touch[1])) ?? 0
            if(corr1>0.85 && corr2>0.85){
                print("positive corr 5")
                wattom5.setCorrelationStatus(status: true)
            }else{
                wattom5.setCorrelationStatus(status: false)
            }
            
            corr1 = (pearson(x:wattom6.getBuffer()[0], y:touch[0])) ?? 0
            corr2 = (pearson(x:wattom6.getBuffer()[1], y:touch[1])) ?? 0
            if(corr1>0.85 && corr2>0.85){
                print("positive corr 6")
                wattom6.setCorrelationStatus(status: true)
            }else{
                wattom6.setCorrelationStatus(status: false)
            }
            usleep(correelationFreq)
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

