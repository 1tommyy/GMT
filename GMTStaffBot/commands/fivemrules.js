const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    message.channel.send('https://gmtstudios.com/forums/index.php?/fivem-rules/')
}

exports.conf = {
    name: "fivemrules",
    perm: 0,
    guild: "1304983538071896165"
}