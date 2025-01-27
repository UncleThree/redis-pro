//
//  GlobalContext.swift
//  redis-pro
//
//  Created by chengpanwang on 2021/4/15.
//

import Foundation
import RediStack

class GlobalContext:ObservableObject, CustomStringConvertible {
    @Published var alertVisible:Bool = false
    var alertTitle:String = ""
    var alertMessage:String = ""
    var showSecondButton:Bool = false
    var primaryButtonText:String = "Ok"
    var secondButtonText:String = "Cancel"
    var primaryAction:() throws -> Void = {}
    
    @Published var loading:Bool = false

    
    func showError(_ error:Error) -> Void {
        alertVisible = true
        if error is BizError {
            alertMessage = (error as! BizError).message
        } else if error is RedisError {
            alertMessage = (error as! RedisError).message
        } else {
            alertMessage = "\(error)"
        }
    }

    
    var description: String {
        return "GlobalContext:[alertVisible:\(alertVisible), loading:\(loading)]"
    }
}
