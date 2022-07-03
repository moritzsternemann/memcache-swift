//
//  MemcacheResponseValue.swift
//  
//
//  Created by Moritz Sternemann on 03.07.22.
//

import NIO

public struct MemcacheResponseValue {
    let key: MemcacheKey
    let data: ByteBuffer
    let flags: UInt16
    let bytes: UInt // TODO: Remove?
    let casUnique: UInt64?
}
