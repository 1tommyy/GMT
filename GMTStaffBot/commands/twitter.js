const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    message.channel.send('https://global.com/gmt5m')
}

exports.conf = {
    name: "global",
    perm: 0,
    guild: "1304983538071896165"
}