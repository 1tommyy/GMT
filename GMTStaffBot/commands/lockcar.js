var AsciiTable = require('ascii-table');
const Discord = require('discord.js');
const fs = require('fs');

const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + '\n`!lockcar [spawncode]`',
            "color": 0x57F288,
    }
    return message.channel.send({ embed })
    }
    fivemexports.gmt.execute("UPDATE `gmt_user_vehicles` SET locked = ? WHERE vehicle = ?", [1, params[0]])
    let embed = {
        "title": `Locked Car`,
        "description": `${params[0]} has been set as locked.`,
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": ""
        },
        "timestamp": new Date()
    }
    message.channel.send({ embed })
}

exports.conf = {
    name: "lockcar",
    perm: 7,
    guild: "1304983538071896165",
    support: true,
}