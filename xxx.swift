//
//  xxx.swift
//  SDRApi
//
//  Created by Douglas Adams on 5/15/24.
//

import Foundation

if isCompressed {
  // Opus, UInt8, 2 channel: used for the received opus data
  _opusBuffer = AVAudioCompressedBuffer(format: AVAudioFormat(streamDescription: &_opusASBD)!, packetCapacity: 1, maximumPacketSize: _frameCountOpus)
  
  // Float32, Host, 2 Channel, interleaved
  _interleavedBuffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat(streamDescription: &_opusInterleavedASBD)!, frameCapacity: UInt32(_frameCountOpus))!
  _interleavedBuffer.frameLength = _interleavedBuffer.frameCapacity
  
  // Float32, Host, 2 Channel, non-interleaved
  _nonInterleavedBuffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat(streamDescription: &_nonInterleavedASBD)!, frameCapacity: UInt32(_frameCountOpus * _channelCount))!
  _nonInterleavedBuffer.frameLength = _nonInterleavedBuffer.frameCapacity
  
} else {
  // Float32, BigEndian, 2 Channel, interleaved
  _interleavedBuffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat(streamDescription: &_interleavedBigEndianASBD)!, frameCapacity: UInt32(_frameCountUncompressed))!
  _interleavedBuffer.frameLength = _interleavedBuffer.frameCapacity
  
  // Float32, Host, 2 Channel, non-interleaved
  _nonInterleavedBuffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat(streamDescription: &_nonInterleavedASBD)!, frameCapacity: UInt32(_frameCountUncompressed * _channelCount))!
  _nonInterleavedBuffer.frameLength = _nonInterleavedBuffer.frameCapacity
}
// create the Float32, Host, non-interleaved Ring buffer (actual size will be adjusted to fit virtual memory page size)
let ringBufferSize = (_frameCountOpus * _elementSize * _channelCount * _ringBufferCapacity) + _ringBufferOverage
guard _TPCircularBufferInit( &_ringBuffer, UInt32(ringBufferSize), MemoryLayout<TPCircularBuffer>.stride ) else { fatalError("RxAudioPlayer: Ring Buffer not created") }

_srcNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
  // retrieve the requested number of frames
  var lengthInFrames = frameCount
  TPCircularBufferDequeueBufferListFrames(&self._ringBuffer, &lengthInFrames, audioBufferList, nil, &self._nonInterleavedASBD)
  return noErr
}

_engine.attach(_srcNode)
_engine.connect(_srcNode, to: _engine.mainMixerNode, format: AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                                                           sampleRate: _sampleRate,
                                                                           channels: AVAudioChannelCount(_channelCount),
                                                                           interleaved: false)!)
active = true

// empty the ring buffer
TPCircularBufferClear(&_ringBuffer)

// start processing
do {
  try _engine.start()
} catch {
  fatalError("RxAudioPlayer: Failed to start, error = \(error)")
}
}
