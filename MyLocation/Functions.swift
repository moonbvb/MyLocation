//
//  Functions.swift
//  MyLocation
//
//  Created by DenisSuspitsyn on 27.09.2020.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}
