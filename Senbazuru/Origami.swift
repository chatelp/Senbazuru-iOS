//
//  Origami.swift
//  Senbazuru
//
//  Created by Pierre Chatel on 25/02/15.
//  Copyright (c) 2015 Pierre Chatel. All rights reserved.
//

import Foundation
import UIKit

class SwiftOrigami {
    private var wrappedItem : MWFeedItem;
    
    init(wrappedItem: MWFeedItem) {
        self.wrappedItem = wrappedItem;
    }

    // MARK: -
    // MARK: Wrapper accessors for feed item properties
    
    var date : NSDate {
        get {
            return wrappedItem.date
        }
    }
    
    var title : String {
        get {
            if wrappedItem.title != nil {
                return wrappedItem.title.stringByConvertingHTMLToPlainText()
            } else {
                return "[No Title]"
            }
        }
    }
    
    var summary : String {
        get {
            if wrappedItem.summary != nil {
                return wrappedItem.summary.stringByConvertingHTMLToPlainText()
            } else {
                return "[No Summary]"
            }
        }
    }

    var content : String {
        get {
            if wrappedItem.content != nil {
                return wrappedItem.content.stringByConvertingHTMLToPlainText()
            } else {
                return "[No Content]"
            }
        }
    }
    
    // MARK: -
    // MARK: Accessor for dedicated origami properties
    
    var summaryPlainText : String {
        get {
            if wrappedItem.summary != nil {
                return wrappedItem.summary.stringByConvertingHTMLToPlainText()
            } else {
                return "[No Summary]"
            }
        }
    }
    
    var contentPlainText : String {
        get {
            if wrappedItem.content != nil {
                return wrappedItem.content.stringByConvertingHTMLToPlainText()
            } else {
                return "[No Content]"
            }
        }
    }

    
    
}