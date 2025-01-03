const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

var statusLeaderboard = require(resourcePath + '/statusleaderboard.json')
let descriptionText = ''

exports.runcmd = (fivemexports, client, message, params) => {
    const sortable = Object.fromEntries(
        Object.entries(statusLeaderboard['leaderboard']).sort(([,a],[,b]) => b-a)
    );
    let foundUser = false;
    for (i = 0; i < Object.keys(statusLeaderboard['leaderboard']).length; i++) {
        if (Object.keys(sortable)[i] == message.author.id) {
            let embed = {
                "title": `Leaderboard Info`,
                "description": 'To take part in the competition for **£100 Paypal**, place `discord.gg/gmt5m` in your status.'+'```\nYou are currently '+(i+1)+'/'+Object.keys(statusLeaderboard['leaderboard']).length+' on the leaderboard.```<@'+message.author.id+'>',
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": ""
                },
                "timestamp": new Date()
            }
            message.channel.send({ embed });
            foundUser = true;
            break;
        }
    }
    
    if (!foundUser) {
        // If the user is not found in the leaderboard, show a message indicating they haven't added "discord.gg/gmt5m" in their status.
        message.channel.send("You have not added `discord.gg/gmt5m` to your status.");
    }
}

exports.conf = {
    name: "leaderboard",
    perm: 0,
    guild: "1304983538071896165"
}
