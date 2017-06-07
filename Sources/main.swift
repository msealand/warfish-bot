import Foundation
import SlackKit
import Alamofire

class WarFishBot {
    
    let bot: SlackKit
    
    init(token: String) {
        bot = SlackKit()
        bot.addRTMBotWithAPIToken(token)
        bot.addWebAPIAccessWithToken(token)
        bot.notificationForEvent(.message) { [weak self] (event, client) in
            guard
                let message = event.message,
                let id = client?.authenticatedUser?.id,
                message.text?.contains(id) == true
                else {
                    return
            }
            self?.handleMessage(message)
        }
    }
    
    init(clientID: String, clientSecret: String) {
        bot = SlackKit()
        let oauthConfig = OAuthConfig(clientID: clientID, clientSecret: clientSecret)
        bot.addServer(oauth: oauthConfig)
        bot.notificationForEvent(.message) { [weak self] (event, client) in
            guard
                let message = event.message,
                let id = client?.authenticatedUser?.id,
                message.text?.contains(id) == true
                else {
                    return
            }
            self?.handleMessage(message)
        }
    }
    
    // MARK: Bot logic
    private func handleMessage(_ message: Message) {
        if let text = message.text?.lowercased(), let channel = message.channel {

            print(text)
            
            if text.hasPrefix("<@u5p4qbyd6> game ") {
                let parts = text.split(" ")
                if parts.count > 2 {
                    if let gameId = parts.last {
                        Alamofire.request("http://warfish.net/war/services/rest?_method=warfish.tables.getDetails&_format=json&gid=" + gameId).responseJSON { response in
                            if let JSON = response.result.value {
                                if let rules = ((JSON as? Dictionary<String, Any>)?["_content"] as? Dictionary<String, Any>)?["rules"] {
                                
                                    do {
                                        try self.bot.rtm?.sendMessage("Rules: \(rules)", channelID: channel)
                                    } catch {
                                        print("error sending reply")
                                    }
                                    
                                }
                            }
                        }
                        
                        Alamofire.request("http://warfish.net/war/services/rest?_method=warfish.tables.getState&_format=json&gid=" + gameId).responseJSON { response in
                            if let JSON = response.result.value {
                                print("\(JSON)")
                                
//                                if let rules = ((JSON as? Dictionary<String, Any>)?["_content"] as? Dictionary<String, Any>)?["rules"] {
//                                    
//                                    do {
//                                        try self.bot.rtm?.sendMessage("Rules: \(rules)", channelID: channel)
//                                    } catch {
//                                        print("error sending reply")
//                                    }
//                                    
//                                }
                            }
                        }
                    }
                }
            } else {
                // Not found
                bot.webAPI?.addReaction(name: "question", channel: channel, timestamp: message.ts, success: nil, failure: nil)
            }
        }
    }
}

// With API token
let slackbot = WarFishBot(token: "REPLACE_ME")
// With OAuth
// let slackbot = RobotOrNotBot(clientID: "CLIENT_ID", clientSecret: "CLIENT_SECRET")

RunLoop.main.run()
