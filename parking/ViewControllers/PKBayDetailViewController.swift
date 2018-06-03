//
//  PKBayDetailViewController.swift
//  parking
//
//  Created by Xingping Ding on 2018/4/12.
//  Copyright © 2018 Xingping Ding. All rights reserved.
//

import UIKit
import SwiftyJSON

class PKBayDetailViewController: UIViewController, UIWebViewDelegate{

    var parkingInfo: RealTimeParkingInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .done, target: self, action: #selector(PKBayDetailViewController.back))
        navigationItem.title = parkingInfo?.st_marker_id
        
        // Get historical analysis data
        getAnalysisData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Go back when the back button is pressed
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Get historical analysis data from server
    func getAnalysisData()
    {
        self.view.showHudInView(view: view)
        NetworkTool.sharedTools.getAnalysisData(bayid: (parkingInfo?.bay_id)!) { (analysisData, error) in
            self.view.hideHud()
            if error == nil {
                
                let analysisDataList = analysisData!["prob"]
                
                self.showAnalysisChart(analysisDataList: analysisDataList)
                
                // After geting the analyis data then get the predicted data
                self.getPredictedData()
            }else{
                self.view.showTextHud(content: "Network Error")
            }
        }
    }
    
    // Show historical analysis data using AAChartKit
    func showAnalysisChart(analysisDataList: JSON) {
        let aaChartView = AAChartView()
        let chartViewWidth = self.view.frame.size.width
        let chartViewHeight = CGFloat(300.0)
        aaChartView.frame = CGRect(x:0,y:60,width:chartViewWidth,height:chartViewHeight)
        aaChartView.contentHeight = chartViewHeight-20
        self.view.addSubview(aaChartView)
        aaChartView.scrollEnabled = false
        
        // AAChartModel setting
        var aaChartModel = AAChartModel()
            .chartType(AAChartType.Bar)
            .colorsTheme(["#ef476f",])
            .title("Analysis Data")
            .subtitle("")
            .dataLabelEnabled(false)
            .tooltipValueSuffix("")
            .backgroundColor("#ffffff")
            .animationType(AAChartAnimationType.Bounce)
            .series([
                AASeriesElement()
                    .name("Analysis Data")
                    .data([analysisDataList[0].doubleValue, analysisDataList[1].doubleValue, analysisDataList[2].doubleValue,analysisDataList[3].doubleValue,analysisDataList[4].doubleValue,analysisDataList[5].doubleValue,analysisDataList[6].doubleValue])
                    .toDic()!,
                ])
        
        aaChartModel = aaChartModel
            .categories(["Mon", "Tue", "Wed", "Thu", "Fri","Sat","Sun"])
            .legendEnabled(true)
            .colorsTheme(["#06caf4"])
            .animationType(AAChartAnimationType.Bounce)
            .animationDuration(1200)
        
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
    }
    
    // Get predicted data from server
    func getPredictedData()
    {
        self.view.showHudInView(view: view)
        NetworkTool.sharedTools.getPredictedData(streetmarker: (parkingInfo?.st_marker_id)!) { (predictedData, error) in
            self.view.hideHud()
            if error == nil {
                var predictedDataList = [[Double]]()
                
                var weekNameList = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
                
                var i = 0
                for (_, dayList): (String, JSON) in predictedData!["prob"] {
                    var dataList = [Double]()
                    var j = 0
                    for (_, myData): (String, JSON) in dayList[weekNameList[i]] {
                        // As the screen of iPhone is too small
                        // Only show some times of the data
                        if j == 0 || j == 3 || j == 6 || j == 9 || j == 12 || j == 15 || j == 18 || j == 21 {
                            dataList.append(myData.doubleValue)
                        }
                        j = j + 1
                    }
                    predictedDataList.append(dataList)
                    
                    i = i + 1
                }
                self.showAnalysisChart(predictedDataList: predictedDataList)
            }else{
                self.view.showTextHud(content: "Network Error")
            }
        }
    }
    
    // Show predicted data using AAChartKit
    func showAnalysisChart(predictedDataList: [[Double]]) {
        let aaChartView = AAChartView()
        let chartViewWidth = self.view.frame.size.width
        let chartViewHeight = self.view.frame.size.height-360
        aaChartView.frame = CGRect(x:0,y:360,width:chartViewWidth,height:chartViewHeight)
        aaChartView.contentHeight = chartViewHeight-20
        self.view.addSubview(aaChartView)
        aaChartView.scrollEnabled = false
        
        // AAChartModel setting
        var aaChartModel = AAChartModel()
            .chartType(AAChartType.Bar)
            .colorsTheme(["#fe117c","#ffc069","#06caf4","#7dffc0","#9b43b4","#ef476f","#04d69f"])
            .title("Predicted Data")
            .subtitle("")
            .dataLabelEnabled(false)
            .tooltipValueSuffix("")
            .backgroundColor("#ffffff")
            .animationType(AAChartAnimationType.Bounce)
            .series([
                AASeriesElement()
                    .name("Mon")
                    .data(predictedDataList[0])
                    .toDic()!,
                AASeriesElement()
                    .name("Tue")
                    .data(predictedDataList[1])
                    .toDic()!,
                AASeriesElement()
                    .name("Wed")
                    .data(predictedDataList[2])
                    .toDic()!,
                AASeriesElement()
                    .name("Thu")
                    .data(predictedDataList[3])
                    .toDic()!,
                AASeriesElement()
                    .name("Fri")
                    .data(predictedDataList[4])
                    .toDic()!,
                AASeriesElement()
                    .name("Sat")
                    .data(predictedDataList[5])
                    .toDic()!,
                AASeriesElement()
                    .name("Sun")
                    .data(predictedDataList[6])
                    .toDic()!,])
        
        aaChartModel = aaChartModel
            .categories(["0", "3", "6", "9", "12", "15", "18", "21"])
            .legendEnabled(true)
            .colorsTheme(["#fe117c","#ffc069","#06caf4","#7dffc0","#9b43b4","#ef476f","#04d69f"])
            .animationType(AAChartAnimationType.Bounce)
            .animationDuration(1200)
        
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
    }
}
