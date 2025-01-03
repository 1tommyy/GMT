const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
     
    if (!params[0] || !parseInt(params[0]) || !params[1]) {
        return message.reply('Invalid args! Correct term is: ' + process.env.PREFIX + 'setmoney [permid] [amount]')
    }
    fivemexports.gmt.gmt('getUserSource', [parseInt(params[0])], function(d) {
        let newval = fivemexports.gmt.gmt('kick', [d, `${message.author.username} is adding money to your account.`])
        fivemexports.gmt.execute("UPDATE `gmt_user_moneys` SET bank = ? WHERE user_id = ?", [params[1], params[0]], (result) => {
            if (result) {
                let embed = {
                    "title": "Set Money",
                    "description": `\nPerm ID: **${params[0]}**\namount: **${params[1]}**\n\nAdmin: <@${message.author.id}>`,
                    "color": settingsjson.settings.botColour,
                    "footer": {
                        "text": ""
                    },
                    "timestamp": new Date()
                }
                message.channel.send({ embed })
            } else {
                let embed = {
                    "title": "Failed to set Money",
                    "description": `\nPerm ID: **${params[0]}**\namount: **${params[1]}**`,
                    "color": settingsjson.settings.botColour,
                    "footer": {
                        "text": ""
                    },
                    "timestamp": new Date()
                }
                message.channel.send({ embed })
            }
        })
    })
}

exports.conf = {
    name: "setmoney",
    perm: 7,
    guild: "1304983538071896165"
}