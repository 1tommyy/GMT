const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    if (message.mentions.members.first()) {
        let user = message.mentions.members.first()
        fivemexports.gmt.execute("SELECT user_id FROM `gmt_verification` WHERE discord_id = ?", [user.id], (result) => {
            if (result.length > 0) {
                let embed = {
                    "title": "Perm ID for " + user.user.username,
                    "description": `\n${result[0].user_id}`,
                    "color": 0x57f288,
                    "footer": {
                        "text": ""
                    },
                }
                message.channel.send({ embed })
            } else {
                message.channel.send('No account is linked for this user.')
            }
        });
    } else {
        message.channel.send('You need to mention someone!')
    }
}

exports.conf = {
    name: "permid",
    perm: 1,
    guild: "1304983538071896165",
    support: true,
}