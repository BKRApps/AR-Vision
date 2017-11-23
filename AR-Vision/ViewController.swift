//
//  ViewController.swift
//  AR-Vision
//
//  Created by Birapuram Kumar Reddy on 11/23/17.
//  Copyright © 2017 KRiOSApps. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var tapGesture : UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene()

        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)

        addTapGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()

        removeTapGesture()
    }

}


extension ViewController {
    func addTapGesture() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(tapGesture:)))
        sceneView.addGestureRecognizer(tapGesture!)
    }

    @objc func handleTap(tapGesture:UITapGestureRecognizer){
        let tappedPoint = tapGesture.location(in: sceneView)
        print("Tapped point \(tappedPoint)")


        if let capturedImage = sceneView.session.currentFrame?.capturedImage {
            do {
                let vnCoreModel = try VNCoreMLModel(for: MobileNet().model)
                ClassficationLogic.classify(image: capturedImage, using: vnCoreModel, completionHandler: { [unowned self] (observations, error) in
                    if let listOfObservations = observations, listOfObservations.count>0 {
                        print(listOfObservations);
                        let observation = listOfObservations[0]
                        self.createSCNTextNode(with: observation.identifier, at: nil)
                    } else {
                        print("unable to find the observations")
                    }
                })
            }catch{

            }
        }
    }

    func removeTapGesture() {
        if let _ = tapGesture {
            sceneView.removeGestureRecognizer(tapGesture!)
        }
    }
}


extension ViewController {

    func createSCNTextNode(with text:String, at position:SCNVector3?) {

        let scnText = SCNText(string: text, extrusionDepth: 1.0)

        let scnNode = SCNNode(geometry: scnText)
        let cameraTransformation = self.sceneView.session.currentFrame?.camera.transform

        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.3
        let transformation = simd_mul(cameraTransformation!,translation)
        scnNode.transform = SCNMatrix4(transformation)
        if let cameraEulerAngles = self.sceneView.session.currentFrame?.camera.eulerAngles {
            scnNode.eulerAngles = SCNVector3Make(cameraEulerAngles.x, cameraEulerAngles.y, 0)
        }
        scnNode.scale = SCNVector3Make(0.002, 0.002, 0.002)
        sceneView.scene.rootNode.addChildNode(scnNode)
    }
}
