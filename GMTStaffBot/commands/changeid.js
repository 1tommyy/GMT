const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
  
    if (!params[0] || !(params[1])) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + '\n`!changeid [old perm id] [new perm id]`',
            "color": 0x57F288,
    }
    return message.channel.send({ embed })
    }
    fivemexports['gmt'].execute("SELECT * FROM gmt_user_ids WHERE user_id = ?", [parseInt(params[0])], (change) => {
        fivemexports['gmt'].execute("SELECT * FROM gmt_user_ids WHERE user_id = ?", [parseInt(params[1])], (changeto) => {
            for (i = 0; i < change.length; i++) {
                fivemexports['gmt'].execute('UPDATE gmt_user_ids SET user_id = ? WHERE identifier = ?', [parseInt(params[1]), change[i].identifier])
            }
            for (i = 0; i < changeto.length; i++) {
                fivemexports['gmt'].execute('UPDATE gmt_user_ids SET user_id = ? WHERE identifier = ?', [parseInt(params[0]), changeto[i].identifier])
            }
            fivemexports['gmt'].execute("SELECT * FROM gmt_user_data WHERE user_id = ?", [parseInt(params[0])], async(change) => {
                fivemexports['gmt'].execute("SELECT * FROM gmt_user_data WHERE user_id = ?", [parseInt(params[1])], async(changeto) => {
                    //Change USER DATA
                    await fivemexports['gmt'].execute("DELETE FROM gmt_user_data WHERE user_id = ?", [parseInt(params[0])])
                    await fivemexports['gmt'].execute("DELETE FROM gmt_user_data WHERE user_id = ?", [parseInt(params[1])])
                    for (i = 0; i < change.length; i++) {
                        fivemexports['gmt'].execute('INSERT INTO gmt_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[1]), "GMT:datatable", change[i].dvalue])
                        fivemexports['gmt'].execute('INSERT INTO gmt_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[1]), "GMT:Face:Data", change[i].dvalue])
                        fivemexports['gmt'].execute('INSERT INTO gmt_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[1]), "GMT:home:wardrobe", change[i].dvalue])
                        fivemexports['gmt'].execute('INSERT INTO gmt_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[1]), "GMT:police_records", change[i].dvalue])
                        fivemexports['gmt'].execute('INSERT INTO gmt_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[1]), "GMT:jail:time", change[i].dvalue])
                    }
                    for (i = 0; i < changeto.length; i++) {
                        fivemexports['gmt'].execute('INSERT INTO gmt_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[0]), "GMT:datatable", changeto[i].dvalue])
                        fivemexports['gmt'].execute('INSERT INTO gmt_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[0]), "GMT:Face:Data", changeto[i].dvalue])
                        fivemexports['gmt'].execute('INSERT INTO gmt_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[0]), "GMT:home:wardrobe", changeto[i].dvalue])
                        fivemexports['gmt'].execute('INSERT INTO gmt_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[0]), "GMT:police_records", changeto[i].dvalue])
                        fivemexports['gmt'].execute('INSERT INTO gmt_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[0]), "GMT:jail:time", changeto[i].dvalue])
                    }
                })
            })
            fivemexports['gmt'].execute("SELECT * FROM gmt_user_data WHERE user_id = ?", [parseInt(params[0])], (change) => {
                fivemexports['gmt'].execute("SELECT * FROM gmt_user_data WHERE user_id = ?", [parseInt(params[1])], (changeto) => {
                   // Change USER DATA
                    fivemexports['gmt'].execute("DELETE FROM gmt_user_data WHERE user_id = ?", [parseInt(params[0])])
                    fivemexports['gmt'].execute("DELETE FROM gmt_user_data WHERE user_id = ?", [parseInt(params[1])])
                    setTimeout(() => {

                        for (i = 0; i < change.length; i++) {
                            fivemexports['gmt'].execute('INSERT INTO gmt_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[1]), "GMT:datatable", change[i].dvalue])
                            fivemexports['gmt'].execute('INSERT INTO gmt_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[1]), "GMT:Face:Data", change[i].dvalue])
                            fivemexports['gmt'].execute('INSERT INTO gmt_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[1]), "GMT:home:wardrobe", change[i].dvalue])
                            fivemexports['gmt'].execute('INSERT INTO gmt_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[1]), "GMT:police_records", change[i].dvalue])
                            fivemexports['gmt'].execute('INSERT INTO gmt_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[1]), "GMT:jail:time", change[i].dvalue])
                        }
                        for (i = 0; i < changeto.length; i++) {
                            fivemexports['gmt'].execute('INSERT INTO gmt_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[0]), "GMT:datatable", changeto[i].dvalue])
                            fivemexports['gmt'].execute('INSERT INTO gmt_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[0]), "GMT:Face:Data", changeto[i].dvalue])
                            fivemexports['gmt'].execute('INSERT INTO gmt_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[0]), "GMT:home:wardrobe", changeto[i].dvalue])
                            fivemexports['gmt'].execute('INSERT INTO gmt_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[0]), "GMT:police_records", changeto[i].dvalue])
                            fivemexports['gmt'].execute('INSERT INTO gmt_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[0]), "GMT:jail:time", changeto[i].dvalue])
                        }
                    }, 500);
                })
            })
            fivemexports['gmt'].execute("SELECT * FROM gmt_user_moneys WHERE user_id = ?", [parseInt(params[0])], (change) => {
                fivemexports['gmt'].execute("SELECT * FROM gmt_user_moneys WHERE user_id = ?", [parseInt(params[1])], (changeto) => {
                    for (i = 0; i < change.length; i++) {
                        fivemexports['gmt'].execute('UPDATE gmt_user_moneys SET user_id = ? WHERE user_id = ?', [parseInt(params[1]), change[i].vehicle])
                    }
                    for (i = 0; i < changeto.length; i++) {
                        fivemexports['gmt'].execute('UPDATE gmt_user_moneyss SET user_id = ? WHERE user_id = ?', [parseInt(params[0]), changeto[i].vehicle])
                    }
                })
            })
            fivemexports['gmt'].execute("SELECT * FROM gmt_user_vehicles WHERE user_id = ?", [parseInt(params[0])], (change) => {
                fivemexports['gmt'].execute("SELECT * FROM gmt_user_vehicles WHERE user_id = ?", [parseInt(params[1])], (changeto) => {
                    for (i = 0; i < change.length; i++) {
                        setInterval(() => {
                            fivemexports['gmt'].execute('UPDATE gmt_user_vehicles SET user_id = ? WHERE vehicle = ?', [parseInt(params[1]), change[i].vehicle])
                        }, 2000);
                    }
                    for (i = 0; i < changeto.length; i++) {
                        setInterval(() => {
                            fivemexports['gmt'].execute('UPDATE gmt_user_vehicles SET user_id = ? WHERE vehicle = ?', [parseInt(params[0]), changeto[i].vehicle])
                        }, 2000);
                    }

                })
            })
            fivemexports['gmt'].execute("SELECT * FROM gmt_user_homes WHERE user_id = ?", [parseInt(params[0])], (change) => {
                fivemexports['gmt'].execute("SELECT * FROM gmt_user_homes WHERE user_id = ?", [parseInt(params[1])], (changeto) => {
                    for (i = 0; i < change.length; i++) {
                        fivemexports['gmt'].execute('UPDATE gmt_user_homes SET user_id = ? WHERE home = ?', [parseInt(params[1]), change[i].home])
                    }
                    for (i = 0; i < changeto.length; i++) {
                        fivemexports['gmt'].execute('UPDATE gmt_user_homes SET user_id = ? WHERE home = ?', [parseInt(params[0]), changeto[i].home])
                    }
                })
            })                
        })
    })
    let embed = {
        "title": "Change Perm ID",
        "description": `\nOld Perm ID: **${params[0]}**\nNew Perm ID: **${params[1]}**\n\nAdmin: <@${message.author.id}>`,
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": ""
        },
        "timestamp": new Date()
    }
    message.channel.send({ embed })
}
exports.conf = {
    name: "changeid",
    perm: 11,
    guild: "1304983538071896165"
}