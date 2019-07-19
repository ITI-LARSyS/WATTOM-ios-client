//
//  WattomViewController.swift
//  iWattom
//
//  Created by Filipe Quintal on 17/07/2019.
//  Copyright © 2019 prsma. All rights reserved.
//

import UIKit

class WattomViewController: UIViewController {
    
    
    // variables for the view elements, there should be a way of adding them programmatically to the view so we get an reference, however for now it works OK.
    @IBOutlet weak var wattomTouch: WattomTouchView!
    @IBOutlet weak var wattom1: WattomAnimation!
    @IBOutlet weak var wattom2: WattomAnimation!
    @IBOutlet weak var wattom3: WattomAnimation!
    @IBOutlet weak var wattom4: WattomAnimation!
    @IBOutlet weak var wattom5: WattomAnimation!
    @IBOutlet weak var wattom6: WattomAnimation!
    
    var correlationRunning:Bool =  true;
    var correelationFreq:UInt32 =  800000
    
   // var buffer_size:Int = 40
   // var currentIndex:Int = 0
    
//    might not need these 2 methods now
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
       // fatalError("init(coder:) has not been implemented")
        super.init(coder:aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //thread used for the correlations
        let queue = DispatchQueue(label: "work-queue" , qos: .userInteractive)
        queue.async {
            self.calculateCorreation()
        }
        
        // Do any additional setup after loading the view.
    }
    
    //once the view is ready to get away stop the correlation
    override func viewWillDisappear(_ animated: Bool) {
        self.correlationRunning=false
        super.viewWillDisappear(animated)
        
    }
    
    /*
     copied from the SIGMA library, https://github.com/evgenyneu/SigmaSwiftStatistics , used it here to avoid static calls
     */
    func covariancePopulation(x: [Double], y: [Double]) -> Double? {
        let xCount = Double(x.count)
        let yCount = Double(y.count)
        
        if xCount == 0 { return nil }
        if xCount != yCount { return nil }
        
        if let xMean = average(x),
            let yMean = average(y) {
            
            var sum:Double = 0
            
            for (index, xElement) in x.enumerated() {
                let yElement = y[index]
                
                sum += (xElement - xMean) * (yElement - yMean)
            }
            
            return sum / xCount
        }
        
        return nil
    }
    
    func sum(_ values: [Double]) -> Double {
        return values.reduce(0, +)
    }
    
    func average(_ values: [Double]) -> Double? {
        let count = Double(values.count)
        if count == 0 { return nil }
        return sum(values) / count
    }
    
    
    func standardDeviationPopulation(_ values: [Double]) -> Double? {
        if let variancePopulation = variancePopulation(values) {
            return sqrt(variancePopulation)
        }
        return nil
    }
    
    func variancePopulation(_ values: [Double]) -> Double? {
        let count = Double(values.count)
        if count == 0 { return nil }
        
        if let avgerageValue = average(values) {
            let numerator = values.reduce(0) { total, value in
                total + pow(avgerageValue - value, 2)
            }
            return numerator / count
        }
        return nil
    }
    
    func pearson(x: [Double], y: [Double]) -> Double? {
        if let cov = covariancePopulation(x: x, y: y),
            let σx = standardDeviationPopulation(x),
            let σy = standardDeviationPopulation(y) {
            
            if σx == 0 || σy == 0 { return nil }
            
            return cov / (σx * σy)
        }
        
        return nil
    }

    
    
    func calculateCorreation(){
        
        sleep(2)
        var touch:Array<[Double]>
        var corr1:Double
        var corr2:Double
        while(correlationRunning){
            //calculates the correlation of each wattom view element, this is the worst part of the code , as it still completely static, with a reference for the view elements we could do it with a two dimensions array
            // with a positive correlation we change the wattom correlation flag
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

