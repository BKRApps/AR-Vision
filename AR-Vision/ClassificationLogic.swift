//
//  ClassificationLogic.swift
//  AR-Vision
//
//  Created by Birapuram Kumar Reddy on 11/23/17.
//  Copyright © 2017 KRiOSApps. All rights reserved.
//

import Foundation
import Vision
import CoreML

protocol ClassiicationProtocol {
    static func classify(image :CVPixelBuffer, using model:VNCoreMLModel,completionHandler:@escaping ([VNClassificationObservation]?,ClassificationError) -> ())
}

class ClassficationLogic : ClassiicationProtocol {

     static func classify(image:CVPixelBuffer, using model: VNCoreMLModel, completionHandler: @escaping ([VNClassificationObservation]?,ClassificationError) -> ()) {
        DispatchQueue.global(qos:.userInitiated).async {
            do{
                // create the request and hand over it to request handler
                let vnCoreMLRequest = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                    DispatchQueue.main.async {
                        if let results = request.results as? [VNClassificationObservation], results.count > 0  {
                            completionHandler(results,ClassificationError.unKnown)
                        }else{
                            if let err = error {
                                completionHandler(nil,ClassificationError.errorWithInfo(err.localizedDescription))
                            }else{
                                completionHandler(nil,ClassificationError.unKnown)
                            }
                        }
                    }
                })

                let vnRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: CGImagePropertyOrientation.up, options: [:])
                try vnRequestHandler.perform([vnCoreMLRequest])
            }catch{
                fatalError(error.localizedDescription)
            }
        }
    }
}
