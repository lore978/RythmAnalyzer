//
//  ViewController.swift
//  RythmAnalyzer
//
//  Created by Lorenzo Giannantonio on 22/11/2020.
//

import UIKit
import CoreImage
import AVFoundation
import CoreHaptics
import ImageIO
import Foundation

let rect = CGRect(x: 0, y: 0, width: 300, height: 300)
var imageui : UIImage?
var lastimage : CIImage? = nil
var previouslastimage : CIImage? = nil
var haptic = false
var accessibility = UIAccessibilityTraits.init()
var timer : Timer!
var captureSession = AVCaptureSession()
var count = 0
var stringtoshow = ""
var precalc = Double(0)
var preval = [Int]()
var medium1 = [Float]()
var medium2 = [Float]()
var medium3 = [Float]()
var diffmedium37 = [Float]()
var previousdiffmedium37 = [Float]()
var preferredred = Float(0) ;var preferredgreen = Float(0);var preferredblue = Float(0);
var mean10 = Float(0)
var mean20 = Float(0)
var mean30 = Float(0)
var mean11 = Float(0)
var mean21 = Float(0)
var mean31 = Float(0)
var mean12 = Float(0)
var mean22 = Float(0)
var mean32 = Float(0)
var differences = [Float]()
var signalfree = true
var valuetrigred = Float(0)
var valuetrigblue = Float(0)
var valuetriggreen = Float(0)
var intervals = [Double]()
var redup = true
var greenup = true
var bluup = true
var lasttime = Double(0)
var stepred = 0
var stepgreen = 0
var stepblue = 0
var previousindexcolor = 0
var lastaverage = 0
var average = 0
var filterimage : CIImage?
var analyzing = false
var lastpulsevalid = true
var removenext = false
var listofarythmiavalues = [Float]()
class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var listofpauses = ""
    var cuore = UIImageView()
    var sfondo = UIImageView()
    var text = UITextView()
    var currentCamera: AVCaptureDevice?
    var backCamera: AVCaptureDevice?
    var Imageview = UIImageView()
    let videoDataOutput = AVCaptureVideoDataOutput()
    var previewLayer:CALayer!
    var captureDevice:AVCaptureDevice!
    func getLanguageISO() -> String {
      let locale = String(Locale.preferredLanguages[0].prefix(2))
      return locale
    }
    @objc func timertapped(){
        print("timertapped")
            if !currentCamera!.isTorchActive{
                do {try currentCamera?.lockForConfiguration();
            if currentCamera?.hasTorch ?? false  {if currentCamera?.isTorchModeSupported(.on) == true {currentCamera?.torchMode = .on}}
                    currentCamera?.unlockForConfiguration()} catch {print(error)}
        }
        if let i = lastimage{
            let col = i.average
            if col.max() == col[0] && col[0] > 150 && col[0] < 235 && Float(col[0])/(Float(col[1]) + 1) >= 4 && Float(col[0])/(Float(col[2]) + 1) >= 4 && !analyzing{
                do {try currentCamera?.lockForConfiguration();
                if currentCamera?.isWhiteBalanceModeSupported(.locked) == true {currentCamera?.whiteBalanceMode = .locked}
                    if currentCamera?.isExposureModeSupported(.locked) == true {currentCamera?.exposureMode = .locked};
                    currentCamera?.unlockForConfiguration()
                    analyzing = true
                    stringtoshow = "analyzing";
                    
                } catch {return}
            } else {
                if !analyzing {return}
                if analyzing && col.max() == col[0] && col[0] > 150 && col[0] < 235 && Float(col[0])/(Float(col[1]) + 1) >= 4 && Float(col[0])/(Float(col[2]) + 1) >= 4 {return}
               
                print("vgegr")
                do {try currentCamera?.lockForConfiguration();if currentCamera?.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) == true { currentCamera?.whiteBalanceMode = .continuousAutoWhiteBalance} else
                if currentCamera?.isWhiteBalanceModeSupported(.autoWhiteBalance) == true { currentCamera?.whiteBalanceMode = .autoWhiteBalance}
                if currentCamera?.isExposureModeSupported(.continuousAutoExposure) == true {  currentCamera?.exposureMode = .continuousAutoExposure} else
                if currentCamera?.isExposureModeSupported(.autoExpose) == true {  currentCamera?.exposureMode = .autoExpose}
                    currentCamera?.unlockForConfiguration()} catch {return}
                analyzing = false
                if Float(col[0])/(Float(col[1]) + 1) < 4 || Float(col[0])/(Float(col[2]) + 1) < 4 {stringtoshow  = "Please put your finger on the back camera";return}
                if col[0] <= 150  {stringtoshow = "Please press less or move your finger to cover camera with less thickness";return}
                if col[0] >= 220  {stringtoshow =  "Please press more or move your finger to cover camera with more thickness";return}
            }
        }

    }
    override func viewDidLoad() {
        cuore.image = UIImage(named: "cuore.png")
        cuore.frame = CGRect(x: self.view.bounds.midX - self.view.bounds.width/5, y: self.view.bounds.midY - self.view.bounds.width/5, width: self.view.bounds.width*0.4, height: self.view.bounds.width*0.4)
        sfondo.frame = self.view.frame//CGRect(x: self.view.bounds.midX - self.view.bounds.width*0.4, y: self.view.bounds.midY - self.view.bounds.width*0.4, width: self.view.bounds.width*0.8, height: self.view.bounds.width*0.8)
        text.frame = CGRect(x: self.view.bounds.minX, y: self.view.bounds.maxY * 0.8, width: self.view.bounds.width, height: self.view.bounds.height*0.2)
        text.backgroundColor = .clear
        self.view.addSubview(sfondo)
        self.view.addSubview(cuore)
        self.view.addSubview(text)
        self.text.textAlignment = .center
        self.text.textColor = UIColor(displayP3Red: 0.9, green: 0.9, blue: 0.9, alpha: 0.8)
        self.text.font = UIFont(name: "Futura-CondensedExtraBold", size: view.frame.width / 14)
        self.text.isUserInteractionEnabled = false
        preval.append(0);
        preval.append(0);
        preval.append(0);
        medium1.append(0);
        medium1.append(0);
        medium1.append(0);
        medium2.append(0);
        medium2.append(0);
        medium2.append(0);
        medium3.append(0);
        medium3.append(0);
        medium3.append(0);
        differences.append(0);
        differences.append(0);
        differences.append(0);
        intervals.append(0);
        if timer == nil {timer = Timer.scheduledTimer(timeInterval: TimeInterval(2), target: self, selector: #selector(timertapped), userInfo: nil, repeats: true)}
    }
    

    
    func alertnopermissiontocamera() {
        let code = getLanguageISO()
        switch code {
        case "":
            showAlerttoclose(texttoshow: "",acceptstring: "")
        default:
            showAlerttoclose(texttoshow: "",acceptstring: "")
        }
        return
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) != .authorized
        {AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler:
            { (authorized) in
                DispatchQueue.main.async
                {
                    if authorized
                    {  self.setupDevice()
                        UIView.animate(withDuration: 0.2,
                                     delay: 0,
                                     options: [],
                                     animations: {
                                        self.Imageview.alpha = 1
                        })
                        
                    } else {self.alertnopermissiontocamera()}
                }
            })
        } else {
            DispatchQueue.main.async
            {
            self.setupDevice()
            UIView.animate(withDuration: 0.2,
                         delay: 0,
                         options: [],
                         animations: {
                            self.Imageview.alpha = 1
            })
            }}
    }
    
    func tryhaptic() -> Bool {
      guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return false}
     return true }

    

    
    func showAlert(texttoshow: String, acceptstring: String) {
        let alertController = UIAlertController(title: "!", message:
            texttoshow, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: acceptstring, style: .default))
        self.present(alertController, animated: true, completion: nil)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning);
    }
    func showAlerttoclose(texttoshow: String, acceptstring: String) {
        let alertController = UIAlertController(title: "", message:
            texttoshow, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: acceptstring, style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
 
 

    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [
            .builtInWideAngleCamera,
            .builtInUltraWideCamera,
            .builtInTelephotoCamera
            
        ], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.back)
        let devices = deviceDiscoverySession.devices
        for device in devices {if device.position == .back && backCamera == nil {backCamera = device} }
        currentCamera = backCamera
        setupInputOutput()
    }
    
    func setupInputOutput() {
        captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480;
        do {let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            if captureSession.canAddInput(captureDeviceInput) {
                captureSession.addInput(captureDeviceInput);}
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: .main)
            if captureSession.canAddOutput(videoOutput) {captureSession.addOutput(videoOutput)}
            do {try currentCamera?.lockForConfiguration();
                currentCamera?.setmaxframe()
                if currentCamera?.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) == true { currentCamera?.whiteBalanceMode = .continuousAutoWhiteBalance} else
                if currentCamera?.isWhiteBalanceModeSupported(.autoWhiteBalance) == true { currentCamera?.whiteBalanceMode = .autoWhiteBalance}
                if currentCamera?.isExposureModeSupported(.continuousAutoExposure) == true {  currentCamera?.exposureMode = .continuousAutoExposure} else
                if currentCamera?.isExposureModeSupported(.autoExpose) == true {  currentCamera?.exposureMode = .autoExpose}
                if currentCamera?.isFocusModeSupported(.continuousAutoFocus) == true {  currentCamera?.focusMode = .continuousAutoFocus} else {
                    if currentCamera?.isFocusModeSupported(.autoFocus) == true {  currentCamera?.focusMode = .autoFocus}
                }
                //if ((currentCamera?.isLowLightBoostSupported) != nil) {  currentCamera?.automaticallyEnablesLowLightBoostWhenAvailable = true}
                
                } catch {print("no lock of camera available")}
            
            currentCamera?.unlockForConfiguration();
            
            captureSession.startRunning()} catch {print(error)}
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait
        self.text.text = stringtoshow
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
        lastimage = CIImage(cvImageBuffer: pixelBuffer)
            
            if let i = lastimage{
                /*
                let diffusion1 = CIFilter(name: "CIGaussianBlur")
                diffusion1?.setValue(i, forKey: kCIInputImageKey)
                diffusion1?.setValue(300, forKey: kCIInputRadiusKey)
                let diffusion2 = CIFilter(name: "CIGaussianBlur")
                diffusion2?.setValue(lastimage, forKey: kCIInputImageKey)
                diffusion2?.setValue(0, forKey: kCIInputRadiusKey)
                let effect = CIFilter(name: "CIDifferenceBlendMode")
                effect?.setValue(i, forKey: kCIInputImageKey)
                effect?.setValue(lastimage, forKey: kCIInputBackgroundImageKey)
                let image = (effect?.outputImage)!*/
                
                let effect2 = CIFilter(name: "CISubtractBlendMode")
                let effect3 = CIFilter(name: "CIMultiplyBlendMode")
                effect3?.setValue(filterimage, forKey: kCIInputImageKey)
                effect3?.setValue(i, forKey: kCIInputBackgroundImageKey)
                if (effect3?.outputImage ?? i).averageColor == true { UIView.animate(withDuration: 0.3,
                                                                delay: 0,
                                                                options: [.curveEaseOut],
                                                                animations: {
                                                                  self.cuore.alpha = 1
                                                   }, completion:{_ in
                                                      UIView.animate(withDuration: 0.1,
                                                                    delay: 0,
                                                                    options: [.curveEaseIn],
                                                                    animations: {
                                                                   self.cuore.alpha = 0
                                                       }, completion:{_ in
                                                       })
                                                   })
                let effect = CIFilter(name: "CIDifferenceBlendMode")
                effect?.setValue(previouslastimage, forKey: kCIInputImageKey)
                effect?.setValue(i, forKey: kCIInputBackgroundImageKey)
                effect2?.setValue(effect?.outputImage, forKey: kCIInputImageKey)
                effect2?.setValue(i, forKey: kCIInputBackgroundImageKey)
                }; //if let i = (effect2?.outputImage) {filterimage = i;}
                sfondo.image = UIImage(ciImage: effect3?.outputImage ?? i )
            }}}
    
    func alert(type: Int, color: Int) {
        switch type {
        case 0:
            switch color {
            case 0:
                print("seemsred")
            case 1:
                print("seemsblue")
            default:
                print("seemsgreen")
            }
        default:
            if color != previousindexcolor || !analyzing{previousindexcolor = color;intervals.removeAll();preferredred = 0;preferredblue = 0;preferredgreen = 0;return}
            previousindexcolor = color;
            var difffromstandarddiffmedium = Float(0)
            
            for i in 0...diffmedium37.count - 1 {
                //normalize
                let max = diffmedium37.max() ?? 1
                let min = diffmedium37.min() ?? 0
                for i in 0...diffmedium37.count - 1{
                    diffmedium37[i] = (diffmedium37[i] - min)/(max - min)
                }
                
                if previousdiffmedium37.count < diffmedium37.count {previousdiffmedium37.append(diffmedium37[i]);continue}
                if previousdiffmedium37.count > diffmedium37.count {previousdiffmedium37.removeFirst()}
                difffromstandarddiffmedium += abs(diffmedium37[i] - previousdiffmedium37[i])
                previousdiffmedium37[i] = diffmedium37[i]
            }
            print(difffromstandarddiffmedium)
            if difffromstandarddiffmedium > 5 {diffmedium37.removeAll();removenext = true;return}
            
            let now = NSDate().timeIntervalSinceReferenceDate
            if removenext {lasttime = now;removenext = false;return}
            let interval = now - lasttime
            lasttime = now
            
            
            intervals.append(interval)
            if intervals.count > 11 {analyze()}
                AudioServicesPlaySystemSound(4095);
        }
    }

    func analyze() {
        while intervals.count > 11 {intervals.removeFirst()}
        let d = intervals.last ?? 0
        let f = String(d)
        listofpauses.append(String(f.prefix(3)) + "'' ,")   //  (String(intervals.last()).prefix(3)
        
        var mean = Double(0)
        var deviationfrommean = [Double]()
        var devofdeviationfrommean = Double(0)
        for i in 0...intervals.count - 1{mean += intervals[i]}
        mean = mean/Double(intervals.count)
        for i in 0...intervals.count - 1{deviationfrommean.append(abs(intervals[i] - mean)/((intervals[i] + mean)/2))}
        //calculatingaritmia
        for i in 0...deviationfrommean.count - 3{devofdeviationfrommean += deviationfrommean[i]*2 - (deviationfrommean[i + 1] - deviationfrommean[i + 2])}
        let arrvalue = 100*abs(devofdeviationfrommean/Double(deviationfrommean.count - 2))
        listofarythmiavalues.append(Float(arrvalue))
        stringtoshow = String(String(arrvalue).prefix(7))
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?){
        if motion == .motionShake {
            UIPasteboard.general.string = listofpauses
            print(listofpauses)
        }
        }
}



extension CIImage {
    var average : [Int] {
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: self, kCIInputExtentKey: self.extent]) else { return [0,0,0] }
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(filter.outputImage!, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        let red = Int(bitmap[0]); let blue = Int(bitmap[1]); let green = Int(bitmap[2]);
        return [red,blue,green]
    }
    
    
    
    var averageColor: Bool {
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: self, kCIInputExtentKey: self.extent]) else { return false }
        guard let outputImage = filter.outputImage else { return false }
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        let red = Int(bitmap[0]); let blue = Int(bitmap[1]); let green = Int(bitmap[2]); let now = NSDate().timeIntervalSinceReferenceDate
        let interval = (now - precalc)/1000000
        let valuetoreturn = [Float(red - preval[0])/Float(interval),Float(green - preval[1])/Float(interval),Float(blue - preval[2])/Float(interval)]
        medium1.append(valuetoreturn[0])
        medium2.append(valuetoreturn[1])
        medium3.append(valuetoreturn[2])
        if medium1.count > 17 {medium1.removeFirst()}
        if medium2.count > 17 {medium2.removeFirst()}
        if medium3.count > 17 {medium3.removeFirst()} else {return(false)}
        mean10 = 0
        mean20 = 0
        mean30 = 0
        mean11 = 0
        mean21 = 0
        mean31 = 0
        mean12 = 0
        mean22 = 0
        mean32 = 0
        for i in 0...16{
            if i > 13 {
                mean10 += medium1[i]/3
                mean20 += medium2[i]/3
                mean30 += medium3[i]/3
            }
            if i > 9 {
                mean11 += medium1[i]/7
                mean21 += medium2[i]/7
                mean31 += medium3[i]/7
            }
            mean12 += medium1[i]/17
            mean22 += medium2[i]/17
            mean32 += medium3[i]/17}
       
        //print(mean12)
        diffmedium37.append(valuetoreturn[0] - mean12)
        if diffmedium37.count > 20 {diffmedium37.removeFirst()}
        differences = [(differences[0] + abs(mean10 - mean12))/2,(differences[1] + abs(mean20 - mean22))/2,(differences[2] + abs(mean30 - mean32))/2]
        if differences.max() == differences[0] {preferredred += 1} else if differences.max() == differences[1] {preferredblue += 1} else if differences.max() == differences[2] {preferredgreen += 1}
        preval[0] = red;preval[1] = green; preval[2] = blue
        switch [preferredred,preferredblue,preferredgreen].max() {
        case preferredred:
            if preferredred > 200 {
                if valuetoreturn[0] > mean10 && stepred == 0 {stepred = 1}
                if stepred == 1 && mean10 > mean11 {stepred = 2}
                if stepred == 2 && mean11 > mean12 {stepred = 3}
                if stepred == 3 && signalfree && !redup{redup = true;ViewController().alert(type: 1, color: 0);signalfree = false;DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {signalfree = true};return true}
                if (mean10 < mean11 || valuetoreturn[0] < mean11) && mean11 < mean12 && signalfree && redup{filterimage = lastimage;stepred = 0;redup = false}
            } else {ViewController().alert(type: 0, color: 0)}
        case preferredblue:
            if preferredblue > 200 {
                if valuetoreturn[1] > mean20 && stepblue == 0 {stepblue = 1}
                if stepblue == 1 && mean20 > mean21 {stepblue = 2}
                if stepblue == 2 && mean21 > mean22 {stepblue = 3}
                if stepblue == 3 && signalfree && !bluup{bluup = true;ViewController().alert(type: 1, color: 1);signalfree = false;DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {signalfree = true};return true}
                if (mean20 < mean21 || valuetoreturn[1] < mean21) && mean21 < mean22 && signalfree && bluup {filterimage = lastimage;stepblue = 0;bluup = false}
            } else {ViewController().alert(type: 0, color: 1)}
        default:
            if preferredgreen > 200 {
                if valuetoreturn[2] > mean30 && stepgreen == 0 {stepgreen = 1}
                if stepgreen == 1 && mean30 > mean31 {stepgreen = 2}
                if stepgreen == 2 && mean31 > mean32 {stepgreen = 3}
                if stepgreen == 3 && signalfree && !greenup{greenup = true;ViewController().alert(type: 1, color: 2);signalfree = false;DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {signalfree = true};return true}
                if (mean30 < mean31 || valuetoreturn[2] < mean31)  && mean31 < mean32 && signalfree && greenup {filterimage = lastimage;stepgreen = 0;greenup = false}
            } else {ViewController().alert(type: 0, color: 2)}
        }

        
        
        return (false)
    }
}

extension AVCaptureDevice {
    func setmaxframe() {
        if let range = activeFormat.videoSupportedFrameRateRanges.first
    {do {
        activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(range.maxFrameRate))
        print(range,range.maxFrameRate)
    }
    }}
}
