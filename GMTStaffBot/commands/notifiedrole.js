const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = async (fivemexports, client, message, params) => {
    let embed = {
        "title": "Stay Notified",
        "description": "React to this message to receive pings from the <@&1253820931063681137> role, if you'd like frequent pings regarding announcements, updates, and server status changes.",
        "color": settingsjson.settings.botColour,
        "author": {
            name: "GMT", 
           // icon_url: "" 
        },
        "thumbnail": {
            url: "https://cdn.discordapp.com/avatars/1225506176116985976/34662f589ae5b42f26d8b29aeb652237.webp?size=1024&format=webp&width=0&height=256" 
        }
    };
    const sentMessage = await message.channel.send({ embed });
    const bellEmoji = '🔔'; 
    await sentMessage.react(bellEmoji);
};

exports.conf = {
    name: "notified",
    perm: 11,
    guild: "1304983538071896165"
};
