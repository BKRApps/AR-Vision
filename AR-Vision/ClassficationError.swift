//
//  ClassficationErrors.swift
//  AR-Vision
//
//  Created by Birapuram Kumar Reddy on 11/23/17.
//  Copyright © 2017 KRiOSApps. All rights reserved.
//

import Foundation

enum ClassificationError: Error {
    case noError
    case errorWithInfo(String)
    case unKnown
}
