const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    message.channel.send('You can buy merch from our store here: https://merch.gmtstudios.com/')
}

exports.conf = {
    name: "merch",
    perm: 0,
    guild: "1304983538071896165"
}