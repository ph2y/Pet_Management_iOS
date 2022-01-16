//
//  EmailVerificationTimer.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/16.
//

import UIKit;

class EmailVerificationTimer {
    // Email verification time limit (by second)
    var verificationTimeLeft = 600;
    var verificationTimer: Timer?;
    var timerFireHandler: (String) -> Void;
    var timeoutHandler: () -> Void;
    
    init (timerFireHandler: @escaping (String) -> Void, timeoutHandler: @escaping () -> Void) {
        self.timerFireHandler = timerFireHandler;
        self.timeoutHandler = timeoutHandler;
    }
    
    // objc func onTimerFires
    // No Param
    // Return Void
    // Update verification time left on every second
    @objc func onTimerFiresEverySec() {
        if (self.verificationTimeLeft == 0) {
            self.timeoutTimeLimitTimer();
        }
        self.verificationTimeLeft -= 1;
        self.timerFireHandler(self.getLeftTimeFormattedStr());
    }
    
    // func getLeftTImeFormattedStr
    // No Param
    // Return String - left time string formatted as mm:ss
    func getLeftTimeFormattedStr() -> String {
        return "\(self.verificationTimeLeft / 60):\(self.verificationTimeLeft % 60)";
    }
    
    // func isTimerRunning
    // No Param
    // Return Bool - timer is running or not
    func isTimerRunning() -> Bool {
        return self.verificationTimer != nil && self.verificationTimer!.isValid;
    }
    
    // func startTimeLimitTimer
    // Param - startHandler: (String) -> Void - Function which does UI operation for startTimer with given timeLimitStr
    // Return Void
    // Initialize verificiation timelimit timer & start counting
    func startTimeLimitTimer(startHandler: (String) -> Void) {
        if self.verificationTimer != nil && self.verificationTimer!.isValid {
            self.verificationTimer!.invalidate();
        }
        
        self.verificationTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFiresEverySec), userInfo: nil, repeats: true);
        self.verificationTimeLeft = 600;
        startHandler(self.getLeftTimeFormattedStr());
    }
    
    // func stopTimeLimitTimer
    // Param - stopHandler: () -> Void - Function which does UI operation for stopTimer
    // Return Void
    // Stop verificiation timelimit timer & reset verification time left
    func stopTimeLimitTimer(stopHandler: () -> Void) {
        if (self.verificationTimer != nil) {
            self.verificationTimer?.invalidate();
        }
        self.verificationTimeLeft = 600;
        stopHandler();
    }
    
    // func timeoutTimeLimitTimer
    // Param - timeoutHandler: () -> Void - Function which does following operation for timeout
    // Return Void
    // Call timeoutHandler for timeout
    func timeoutTimeLimitTimer() {
        self.timeoutHandler();
    }
}
