//
//  ViewController.swift
//  Filterer
//
//  Created by Martin Saporiti on 29/1/16.
//  Copyright © 2016 FluxIT. All rights reserved.
//

import UIKit

class ViewController: UIViewController,
            UIImagePickerControllerDelegate,
            UINavigationControllerDelegate {
    
    
    var filteredImage : UIImage?
    var originalImage : UIImage?
    var isShowingOriginal : Bool = true
    
    var extent: CGRect!
    var scaleFactor: CGFloat!
    
    let context = CIContext(options: nil)
 

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet weak var bottomMenu: UIView!
    
    @IBOutlet var secondaryMenu: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        scaleFactor = UIScreen.mainScreen().scale
        originalImage = imageView.image
        filteredImage =  imageView.image
        isShowingOriginal = true
    }
    
    @IBAction func onNewPhoto(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default,
            handler: {action in
                self.showCamera()
        
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default,
            handler: {action in
                self.showAlbum()
                
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel,
            handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    
    @IBAction func onShare(sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    // Acción que prende la cámara.
    func showCamera(){
        hideSecondaryMenu()
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        presentViewController(cameraPicker, animated: true, completion: nil)
        
    }
 
    
    // Acción que muestra la librería de fotos.
    func showAlbum(){
        hideSecondaryMenu()
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            originalImage = image
            filteredImage = image
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }


    @IBAction func onFilter(sender: UIButton) {
        if(sender.selected){
            hideSecondaryMenu()
            sender.selected = false
        }else{
            showSecondaryMenu()
            sender.selected = true
        }
        
    }
    
    // Show the secondary menu
    func showSecondaryMenu(){
        // Add de submenu
        view.addSubview(secondaryMenu)

        // Define constraints
        let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(bottomMenu.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(bottomMenu.rightAnchor)
        let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        
        // Activate the constraints.
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        view.layoutIfNeeded()
        
        self.secondaryMenu.alpha = 0

        UIView.animateWithDuration(0.4){
            self.secondaryMenu.alpha = 1.0
        }
    }
    
    // Hide the secondary menu.
    func hideSecondaryMenu(){
        filterButton.selected = false
        UIView.animateWithDuration(0.4, animations: {
            self.secondaryMenu.alpha = 0
            }){ completed in
                // Resuelve el problema del doble click rápido.
                if(completed){
                    self.secondaryMenu.removeFromSuperview()
                }
            }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // Acción que se dispara para comparar las fotos: original y filtrada
    @IBAction func onCompareToggle(sender: AnyObject) {
        if (isShowingOriginal){
            imageView.image = filteredImage
            isShowingOriginal = false
        } else {
            imageView.image = originalImage
            isShowingOriginal = true
        }
        
    }
    
    
    
    
    // -------- FILTROS ---------

    
    @IBAction func onTeseoToggle(sender: AnyObject) {
        
        let inputImage = CIImage(image:originalImage!)
        
        let filter = CIFilter(name:"CIColorClamp")
        filter!.setValue(inputImage, forKey: kCIInputImageKey)
        
        let lowerLevel = CIVector(x: 0.1, y: 0.1, z: 0.3, w: 0)
        filter!.setValue(lowerLevel, forKey: "inputMinComponents")
        let upperLevel = CIVector(x: 0.5, y: 0.7, z: 0.9, w: 1)
        filter!.setValue(upperLevel, forKey: "inputMaxComponents")
        
        filteredImage = UIImage(CGImage: context.createCGImage(filter!.outputImage!,
            fromRect: filter!.outputImage!.extent))
        
        isShowingOriginal = false
        imageView.image = filteredImage
    }
    
   
    // ATHOS
    @IBAction func onAthosToggle(sender: AnyObject) {
        
        let inputImage = CIImage(image:originalImage!)
        
        let filter = CIFilter(name:"CIPhotoEffectFade")
        filter!.setValue(inputImage, forKey: kCIInputImageKey)
        
        filteredImage = UIImage(CGImage: context.createCGImage(filter!.outputImage!,
            fromRect: filter!.outputImage!.extent))
        
        isShowingOriginal = false
        imageView.image = filteredImage
        
    }
    
    @IBAction func onCronoToggle(sender: AnyObject) {
        let inputImage = CIImage(image:originalImage!)
        
        let filter = CIFilter(name:"CIPhotoEffectProcess")
        filter!.setValue(inputImage, forKey: kCIInputImageKey)
        
        filteredImage = UIImage(CGImage: context.createCGImage(filter!.outputImage!,
            fromRect: filter!.outputImage!.extent))
        
        isShowingOriginal = false
        imageView.image = filteredImage
    }
    
    @IBAction func onLinoToggle(sender: AnyObject) {
        let inputImage = CIImage(image:originalImage!)
        
        let filter = CIFilter(name:"CIPhotoEffectMono")
        filter!.setValue(inputImage, forKey: kCIInputImageKey)
        
        filteredImage = UIImage(CGImage: context.createCGImage(filter!.outputImage!,
            fromRect: filter!.outputImage!.extent))
        
        isShowingOriginal = false
        imageView.image = filteredImage
    }
    
    
    @IBAction func onFluxitToggle(sender: AnyObject) {
        
        let fluxitImage = CIImage(image: UIImage(named:"fluxit")!)
        
        let beginImage = CIImage(image: filteredImage!)
        let filter = CIFilter(name:"CIOverlayBlendMode")
        
        filter!.setValue(fluxitImage, forKey:kCIInputImageKey)
        filter!.setValue(beginImage, forKey:kCIInputBackgroundImageKey)
        filteredImage = UIImage(CGImage: context.createCGImage(filter!.outputImage!,
            fromRect: filter!.outputImage!.extent))
        imageView.image = filteredImage
        
    }
    
    //        let beginImage = CIImage(image: filteredImage!)
    //        let vignetteFilter = CIFilter(name:"CIVignette")
    //        vignetteFilter!.setValue(beginImage, forKey:kCIInputImageKey)
    //        vignetteFilter!.setValue(3.5, forKey:"inputIntensity")
    //        vignetteFilter!.setValue(30, forKey:"inputRadius")
    //
    //        isShowingOriginal = false
    //        filteredImage = UIImage(CGImage: context.createCGImage(vignetteFilter!.outputImage!,
    //            fromRect: vignetteFilter!.outputImage!.extent))
    //
    //        imageView.image = filteredImage
}

