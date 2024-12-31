const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    message.channel.send('use the command `/apply`')
}

exports.conf = {
    name: "staffapp",
    perm: 0,
    guild: "1304983538071896165"
}