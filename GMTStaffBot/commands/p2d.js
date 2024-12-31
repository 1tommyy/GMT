const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    if (params[0] && parseInt(params[0])) {
        fivemexports.gmt.execute("SELECT discord_id FROM `gmt_verification` WHERE user_id = ?", [params[0]], (result) => {
            if (result.length > 0) {
                let embed = {
                    "title": "Discord Account for " + params[0] + "",
                    "description": `\n\n Linked Discords: \n<@${result[0].discord_id}> \n\nVerified Discord: \n<@${result[0].discord_id}>`,
                    "color": settingsjson.settings.botColour,
                    "footer": {
                        "text": 'GMT Droid'
                    },
                    "timestamp": new Date()
                }
                message.channel.send({ embed })
            } else {
                let embed = {
                    "title": "Discord Account for " + params[0] + "",
                    "description": `\n\n Linked Discords: \nNon Found \n\nVerified Discord: \n<@${result[0].discord_id}>`,
                    "color": settingsjson.settings.botColour,
                    "footer": {
                        "text": 'GMT Droid'
                    },
                    "timestamp": new Date()
                }
                message.channel.send({ embed })
            }
        });
    } else {
        let embed = {
            "title": "Discord Account for " + params[0] + "",
            "description": `\n\n Linked Discords: \n<@${result[0].discord_id}> \n\nVerified Discord: \nNon Found`,
            "color": settingsjson.settings.botColour,
            "footer": {
                "text": 'GMT Droid'
            },
            "timestamp": new Date()
        }
        message.channel.send({ embed })
    }
}

exports.conf = {
    name: "p2d",
    perm: 1,
    guild: "1304983538071896165",
    support: true,
}