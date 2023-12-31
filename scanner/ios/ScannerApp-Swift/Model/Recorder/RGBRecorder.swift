//
//  MovieRecorder.swift
//  LiDARDepth
//
//  Created by Zheren Xiao on 2020-09-24.
//  Copyright © 2020 jx16. All rights reserved.
//

// This file is based on the MovieRecorder in Apple's sample app AVMultiCamPip

import AVFoundation
import Foundation

class RGBRecorder: Recorder {
    typealias T = CVPixelBuffer
    
    private let rgbRecorderQueue = DispatchQueue(label: "rgb recorder queue")
    
    private var assetWriter: AVAssetWriter?
    private var assetWriterVideoInput: AVAssetWriterInput?
    private var assetWriterInputPixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var videoSettings: [String: Any]
    
    private var count: Int32 = 0
    
    init(videoSettings: [String: Any]) {
        self.videoSettings = videoSettings
    }
    
    func prepareForRecording(dirPath: String, filename: String, fileExtension: String = "mp4") {
        
        rgbRecorderQueue.async {
            
            self.count = 0
            
            let outputFilePath = (dirPath as NSString).appendingPathComponent((filename as NSString).appendingPathExtension(fileExtension)!)
            let outputFileUrl = URL(fileURLWithPath: outputFilePath)
            
            guard let assetWriter = try? AVAssetWriter(url: outputFileUrl, fileType: .mp4) else {
                print("Failed to create AVAssetWriter.")
                return
            }
            
            let assetWriterVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: self.videoSettings)
            
            let assetWriterInputPixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterVideoInput, sourcePixelBufferAttributes: nil)
            
            assetWriterVideoInput.expectsMediaDataInRealTime = true
            assetWriter.add(assetWriterVideoInput)
            
            self.assetWriter = assetWriter
            self.assetWriterVideoInput = assetWriterVideoInput
            self.assetWriterInputPixelBufferAdaptor = assetWriterInputPixelBufferAdaptor
        }
        
    }
    
    /// write one rgb frame
    func update(_ buffer: CVPixelBuffer, timestamp: CMTime?) {
        
        guard let timestamp = timestamp else {
            return
        }
        
        rgbRecorderQueue.async {
            
            guard let assetWriter = self.assetWriter else {
                print("Error! assetWriter not initialized.")
                return
            }
            
            print("Saving video frame \(self.count) ...")
            
            if assetWriter.status == .unknown {
                assetWriter.startWriting()
                assetWriter.startSession(atSourceTime: timestamp)
                
                if let adaptor = self.assetWriterInputPixelBufferAdaptor {
                    
                    // incase adaptor not ready
                    // not sure if this is necessary
                    while !adaptor.assetWriterInput.isReadyForMoreMediaData {
                        print("Waiting for assetWriter...")
                        usleep(10)
                    }
                    
                    adaptor.append(buffer, withPresentationTime: timestamp)
                }
                
            } else if assetWriter.status == .writing {
                
//                print("Status .writing. Accually saving \(self.count) ...")
				if let adaptor = self.assetWriterInputPixelBufferAdaptor {
					while !adaptor.assetWriterInput.isReadyForMoreMediaData {
						print("Waiting for assetWriter...")
						usleep(10)
					}
					
					adaptor.append(buffer, withPresentationTime: timestamp)
				}
            }
            
            self.count += 1
        }
    }
    
    /// write one rgb frame
    func update(buffer: CMSampleBuffer) {
        
        rgbRecorderQueue.async {
            
            guard let assetWriter = self.assetWriter else {
                print("Error! assetWriter not initialized.")
                return
            }
            
            if assetWriter.status == .unknown {
                assetWriter.startWriting()
                assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(buffer))
            } else if assetWriter.status == .writing {
                if let input = self.assetWriterVideoInput, input.isReadyForMoreMediaData {
                    input.append(buffer)
                }
            }
        }
    }
    
    func finishRecording() {
        
        rgbRecorderQueue.async {
            
            guard let assetWriter = self.assetWriter else {
                print("Error!")
                return
            }
            
            self.assetWriter = nil
            
            assetWriter.finishWriting {
                print("Finished writing video.")
            }
        }
    }
}
