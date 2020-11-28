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
var audio = false
var lasttime = Double(0)
class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
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
  
    }
    override func viewDidLoad() {
        cuore.image = UIImage(named: "cuore.png")
        cuore.frame = CGRect(x: self.view.bounds.midX - self.view.bounds.width/5, y: self.view.bounds.midY - self.view.bounds.width/5, width: self.view.bounds.width*0.4, height: self.view.bounds.width*0.4)
        sfondo.frame = CGRect(x: self.view.bounds.midX - self.view.bounds.width*0.25, y: self.view.bounds.maxY*0.05, width: self.view.bounds.width*0.5, height: self.view.bounds.width*0.5)
        text.frame = CGRect(x: self.view.bounds.minX, y: self.view.bounds.maxY * 0.8, width: self.view.bounds.width, height: self.view.bounds.height*0.2)
        text.backgroundColor = .darkGray
        self.view.addSubview(cuore)
        self.view.addSubview(sfondo)
        self.view.addSubview(text)
        self.text.textAlignment = .center
        self.text.textColor = UIColor(displayP3Red: 0.7, green: 0, blue: 0, alpha: 1)
        self.text.font = UIFont(name: "Futura-CondensedExtraBold", size: view.frame.width / 6)
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
        case "ar":
            showAlerttoclose(texttoshow: "سيقومسيقوم التطبيق بالتسجيل على بيانات جهازك المستخرجة من الصور للمقارنة والعثور على أكثرها تشابهًا. لن يتم مشاركة البيانات بأي شكل من الأشكال. قبوللا يمكن للتطبيق تحليل البيئة إذا لم تمنح الإذن للوصول إلى الكاميرا.",acceptstring: "")
        case "fi":
            showAlerttoclose(texttoshow: "Sovellus ei voi analysoida ympäristöä, jos et anna lupaa käyttää kameraa.",acceptstring: "")
        case "fr":
            showAlerttoclose(texttoshow: "L'application ne peut pas analyser l'environnement si vous ne donnez pas la permission d'accéder à la caméra.",acceptstring: "")
        case "ja":
            showAlerttoclose(texttoshow: "カメラへのアクセスを許可しないと、アプリは環境を分析できません。",acceptstring: "")
        case "it":
            showAlerttoclose(texttoshow: "L'app non può analizzare l'ambiente se non si autorizza l'accesso alla fotocamera.",acceptstring: "")
        case "pt":
            showAlerttoclose(texttoshow: "O aplicativo não pode analisar o ambiente se você não der permissão para acessar a câmera.",acceptstring: "")
        case "es":
            showAlerttoclose(texttoshow: "La aplicación no puede analizar el entorno si no da permiso para acceder a la cámara.",acceptstring: "")
        case "sv":
            showAlerttoclose(texttoshow: "Appen kan inte analysera miljön om du inte ger behörighet att komma åt kameran.",acceptstring: "")
        case "de":
            showAlerttoclose(texttoshow: "Die App kann die Umgebung nicht analysieren, wenn Sie keine Berechtigung zum Zugriff auf die Kamera erteilen.",acceptstring: "")
        case "ca":
            showAlerttoclose(texttoshow: "L'aplicació no pot analitzar l'entorn si no doneu permís per accedir a la càmera.",acceptstring: "")
        case "cs":
            showAlerttoclose(texttoshow: "Pokud neudělíte přístup k fotoaparátu, aplikace nemůže analyzovat prostředí.",acceptstring: "")
        case "zh":
            showAlerttoclose(texttoshow: "如果您未授予访问相机的权限，则该应用无法分析环境。",acceptstring: "")
        case "ko":
            showAlerttoclose(texttoshow: "카메라에 대한 접근 권한을 부여하지 않으면 앱에서 환경을 분석 할 수 없습니다.",acceptstring: "")
        case "hr":
            showAlerttoclose(texttoshow: "Aplikacija ne može analizirati okruženje ako ne date dopuštenje za pristup kameri.",acceptstring: "")
        case "da":
            showAlerttoclose(texttoshow: "Appen kan ikke analysere miljøet, hvis du ikke giver tilladelse til at få adgang til kameraet.",acceptstring: "")
        case "he":
            showAlerttoclose(texttoshow: "האפליקציה לא יכולה לנתח את הסביבה אם אינך נותן הרשאה לגשת למצלמה.",acceptstring: "")
        case "el":
            showAlerttoclose(texttoshow: "Η εφαρμογή δεν μπορεί να αναλύσει το περιβάλλον εάν δεν επιτρέψετε την πρόσβαση στην κάμερα.",acceptstring: "")
        case "hi":
            showAlerttoclose(texttoshow: "यदि आप कैमरा एक्सेस करने की अनुमति नहीं देते हैं तो ऐप पर्यावरण का विश्लेषण नहीं कर सकता है।",acceptstring: "")
        case "id":
            showAlerttoclose(texttoshow: "Aplikasi tidak dapat menganalisis lingkungan jika Anda tidak memberikan izin untuk mengakses kamera.",acceptstring: "")
        case "ms":
            showAlerttoclose(texttoshow: "Aplikasi tidak dapat menganalisis persekitaran jika anda tidak memberikan kebenaran untuk mengakses kamera.",acceptstring: "")
        case "no":
            showAlerttoclose(texttoshow: "Appen kan ikke analysere miljøet hvis du ikke gir tilgang til kameraet.",acceptstring: "")
        case "nl":
            showAlerttoclose(texttoshow: "De app kan de omgeving niet analyseren als je geen toestemming geeft voor toegang tot de camera.",acceptstring: "")
        case "pl":
            showAlerttoclose(texttoshow: "Aplikacja nie może analizować środowiska, jeśli nie zezwolisz na dostęp do kamery.",acceptstring: "")
        case "ro":
            showAlerttoclose(texttoshow: "Aplicația nu poate analiza mediul dacă nu acordați permisiunea de a accesa camera.",acceptstring: "")
        case "ru":
            showAlerttoclose(texttoshow: "Приложение не сможет анализировать окружающую среду, если вы не дадите разрешение на доступ к камере.",acceptstring: "")
        case "sk":
            showAlerttoclose(texttoshow: "Ak neposkytnete povolenie na prístup k fotoaparátu, aplikácia nemôže analyzovať prostredie.",acceptstring: "")
        case "th":
            showAlerttoclose(texttoshow: "แอปไม่สามารถวิเคราะห์สภาพแวดล้อมได้หากคุณไม่อนุญาตให้เข้าถึงกล้อง",acceptstring: "")
        case "tr","tk":
            showAlerttoclose(texttoshow: "Kameraya erişim izni vermezseniz uygulama ortamı analiz edemez.",acceptstring: "")
        case "uk":
            showAlerttoclose(texttoshow: "Додаток не може аналізувати середовище, якщо ви не даєте дозволу на доступ до камери.",acceptstring: "")
        case "hu":
            showAlerttoclose(texttoshow: "Az alkalmazás nem tudja elemezni a környezetet, ha nem engedélyezi a kamera elérését.",acceptstring: "")
        case "vi":
            showAlerttoclose(texttoshow: "Ứng dụng không thể phân tích môi trường nếu bạn không cấp quyền truy cập vào máy ảnh.",acceptstring: "")
        default:
            showAlerttoclose(texttoshow: "The app can't analyze the environment if you do not give permission to access the camera.",acceptstring: "")
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
            .builtInTelephotoCamera,
            .builtInDualCamera,
            .builtInDualWideCamera,
            .builtInTripleCamera
            
        ], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.back)
        let devices = deviceDiscoverySession.devices
        for device in devices {if device.position == .back && backCamera == nil {backCamera = device} }
       
        currentCamera = backCamera
        setupInputOutput()
    }
    
    func setupInputOutput() {
        do {let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            if captureSession.canAddInput(captureDeviceInput) {
                captureSession.addInput(captureDeviceInput);}
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: .main)
            if captureSession.canAddOutput(videoOutput) {captureSession.addOutput(videoOutput)}
            do {try currentCamera?.lockForConfiguration();
                if currentCamera?.hasTorch ?? false{if currentCamera?.isTorchModeSupported(.off) == true {currentCamera?.torchMode = .off}}
                if currentCamera?.isWhiteBalanceModeSupported(.locked) == true { currentCamera?.whiteBalanceMode = .locked}
                if currentCamera?.isExposureModeSupported(.locked) == true {  currentCamera?.exposureMode = .locked}} catch {print("no lock of camera available")}
            captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480;
            currentCamera?.unlockForConfiguration();
            captureSession.startRunning()
        } catch {
            print(error)
        }
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
        lastimage = CIImage(cvImageBuffer: pixelBuffer)
            sfondo.image = UIImage(ciImage: lastimage!)
            if lastimage?.averageColor == true { UIView.animate(withDuration: 0.3,
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
                self.text.text = stringtoshow
            }
            
        }}
    
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
            let now = NSDate().timeIntervalSinceReferenceDate
            let interval = now - lasttime
            intervals.append(interval)
            lasttime = now
            if intervals.count > 15 {analyze()}
            switch audio {
            case false:
                let gen = UISelectionFeedbackGenerator()
                gen.selectionChanged()
            default:
                AudioServicesPlaySystemSound(1104);
            }
        }
    }

    func analyze() {
        while intervals.count > 12 {intervals.removeFirst()}
        var mean = Double(0)
        var deviationfrommean = [Double]()
        var devofdeviationfrommean = Double(0)
        for i in 0...intervals.count - 1{mean += intervals[i]}
        mean = mean/Double(intervals.count)
        for i in 0...intervals.count - 1{deviationfrommean.append(abs(intervals[i] - mean)/((intervals[i] + mean)/2))}
        //calculatingaritmia
        for i in 0...deviationfrommean.count - 3{devofdeviationfrommean += deviationfrommean[i]*2 - (deviationfrommean[i + 1] - deviationfrommean[i + 2])}
        stringtoshow = String(String(100*abs(devofdeviationfrommean/Double(deviationfrommean.count - 2))).prefix(7))
    }
}





extension CIImage {
    var averageColor: Bool {
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: self, kCIInputExtentKey: self.extent]) else { return false }
        guard let outputImage = filter.outputImage else { return false }
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        let red = Int(bitmap[0]); let blue = Int(bitmap[1]); let green = Int(bitmap[2]); let now = NSDate().timeIntervalSinceReferenceDate
        let interval = now - precalc
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
            if i > 6 {
                mean11 += medium1[i]/10
                mean21 += medium2[i]/10
                mean31 += medium3[i]/10
            }
            mean12 += medium1[i]/17
            mean22 += medium2[i]/17
            mean32 += medium3[i]/17}
        print(mean12)
        differences = [(differences[0] + abs(mean10 - mean12))/2,(differences[1] + abs(mean20 - mean22))/2,(differences[2] + abs(mean30 - mean32))/2]
        if differences.max() == differences[0] {preferredred += 1} else if differences.max() == differences[1] {preferredblue += 1} else if differences.max() == differences[2] {preferredgreen += 1}
        preval[0] = red;preval[1] = green; preval[2] = blue
        switch [preferredred,preferredblue,preferredgreen].max() {
        case preferredred:
            if preferredred > 200 {
                if mean10 > mean11 && mean10 > mean12 && valuetoreturn[0] > mean10 && signalfree && !redup{redup = true;ViewController().alert(type: 1, color: 0);signalfree = false;DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {signalfree = true};return true}
                if mean10 < mean11 && valuetoreturn[0] < mean10 && mean10 < mean12 && signalfree {redup = false}
            } else {ViewController().alert(type: 0, color: 0)}
        case preferredblue:
            if preferredblue > 200 {
                if mean20 > mean21 && mean20 > mean22 && valuetoreturn[1] > mean20 && signalfree && !bluup{bluup = true;ViewController().alert(type: 1, color: 1);signalfree = false;DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {signalfree = true};return true}
                if mean20 < mean21 && valuetoreturn[1] < mean20 && mean20 < mean22 && signalfree {bluup = false}
            } else {ViewController().alert(type: 0, color: 1)}
        default:
            if preferredgreen > 200 {
                if mean30 > mean31 && mean30 > mean32 && valuetoreturn[2] > mean30 && signalfree && !greenup{greenup = true;ViewController().alert(type: 1, color: 2);signalfree = false;DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {signalfree = true};return true}
                if mean30 < mean31 && valuetoreturn[2] < mean30  && mean30 < mean32 && signalfree {greenup = false}
            } else {ViewController().alert(type: 0, color: 2)}
        }

        
        return (false)
    }
}
