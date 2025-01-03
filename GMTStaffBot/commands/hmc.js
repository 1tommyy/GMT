const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + '\n`!hmc [spawncode]`',
            "color": 0x57F288,
    }
    return message.channel.send({ embed })
    }
    fivemexports.gmt.execute("SELECT * FROM gmt_user_vehicles WHERE vehicle = ?", [params[0].toLowerCase()], (result) => {
        if (result) {
            let embed = {
                "title": "Car Count",
                "description": `\nThere are **${result.length}** ${params[0]}'s in the city.`,
                "color": 0x3498db,
                "footer": {
                    "text": ""
                },
                //"timestamp": new Date()
            }
            message.channel.send({ embed })
        }
    })
}

exports.conf = {
    name: "hmc",
    perm: 0,
    guild: "1304983538071896165"
}