//
//  MonteCarloFunc.swift
//  MonteCarlo_ex
//
//  Created by Daksh Patel on 2/4/22.
//

import Foundation
import SwiftUI


class MonteCarloEx: NSObject, ObservableObject {
    
    @MainActor @Published var insideData = [(xPoint: Double, yPoint: Double)]()
    @MainActor @Published var outsideData = [(xPoint: Double, yPoint: Double)]()

    @Published var totalGuesses = 0.0
    @Published var Guesses = 200.0
    @Published var interAtomicDistance = 10.0
    @Published var pointsUnderCurve = 0.0
    @Published var integral = 0.0
    
    
    
    ///calculates the height of the bounding box needed
        @MainActor func boundingBoxHeight() -> Double {
            let a = 5.29
            let y = (1/sqrt(Double.pi*pow(a, 3/2)))*exp(0.0/a)
            
            return y
        }
    
    ///calculates the exact overlapping integral
    func exactOverlapIntegral() -> Double {
        let a = 5.29
        let exactIntegral = exp(-interAtomicDistance/a)*(1+(interAtomicDistance/a)+(pow(interAtomicDistance,2)/(3*pow(a,2))))
        return exactIntegral
    }
    
    
    /// calculate the value of the area under the e ^-x curve
    ///
    /// evaluates the integral using monte carlo approach
    
    func calculateOneS() async{
        
        if(interAtomicDistance == 0.0){
            integral = 1.0
        }
        
        let boundingBoxCalculator = BoundingBox()
        
        let newValue = await calculateMonteCarloIntegral( rightEndPoint: interAtomicDistance, maxGuesses: Guesses)
        
       let insidePoints = pointsUnderCurve + newValue
       let totalPoints = totalGuesses + Guesses
        
       let boundingBoxHeight = await boundingBoxHeight()
       let integralVal = (insidePoints/totalPoints) * boundingBoxCalculator.calculateSurfaceArea(numberOfSides: 2, lengthOfSide1: boundingBoxHeight, lengthOfSide2: interAtomicDistance, lengthOfSide3: 0.0)
        
        await updatePointsUnderCurve(pointsUnderCurve: insidePoints)
        await updateTotalGuesses(totalGuesses: totalPoints)
        await updateIntegral(integral: integralVal)
        
    }
    
    ///creating a fucntion  that actual  generates random numbers and figures out where it is inside or outside
    func calculateMonteCarloIntegral(rightEndPoint:Double, maxGuesses: Double) async -> Double{
        
        var numberOfGuesses = 0.0
        var pointsInRadius = 0.0
        var point = (xPoint: 0.0, yPoint: 0.0)
        
    
    /// one s orbitals are the y values of function below for a given r value
    ///            1                   - r
    ///      -------------------- * e ----
    ///      _______________         a0
    ///     /          3 / 2
    ///   |  /  pi  *  a
    ///   |/               0


        var oneSOrbital = 0.0
        var complexConjugate = 0.0
        
        var newInsidePoints : [(xPoint: Double, yPoint: Double)] = []
        var newOutsidePoints : [(xPoint: Double, yPoint: Double)] = []
        
        while numberOfGuesses < maxGuesses {
            
            /* Calculate 2 random values within the box */
            /* Determine the distance from that point to the origin */
            /* If the distance is less than the unit radius count the point being within the Unit Circle */
            let boundingBoxHeight = await boundingBoxHeight()
            point.xPoint = Double.random(in: 0.0...rightEndPoint)
            point.yPoint = Double.random(in: 0.0...boundingBoxHeight)
            
            let a = 5.29 ///Bohr radius
            oneSOrbital = (1/sqrt(Double.pi*pow(a, 3/2)))*exp(-point.xPoint/a)
            
            complexConjugate = (1/sqrt(Double.pi*pow(a, 3/2)))*exp((point.xPoint-interAtomicDistance)/a)
            
            if((oneSOrbital - point.yPoint) >= 0.0 && (complexConjugate - point.yPoint) >= 0.0){
                pointsInRadius += 1.0
                newInsidePoints.append(point)
                
            }
            else {
                newOutsidePoints.append(point)
            }
            
            numberOfGuesses += 1.0
        
        }
        
        return pointsInRadius
    }
    
    @MainActor func updatePointsUnderCurve(pointsUnderCurve: Double){
        self.pointsUnderCurve = pointsUnderCurve
    }
    
    @MainActor func updateTotalGuesses(totalGuesses: Double){
        self.totalGuesses = totalGuesses
    }
    
    @MainActor func updateIntegral(integral: Double){
        self.integral = integral
    }
    
    
}
