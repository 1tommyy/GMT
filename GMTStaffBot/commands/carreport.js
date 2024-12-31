let { Webhook, MessageBuilder } = require('discord-webhook-node');

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0]) {
        return message.reply('Invalid args! Correct term is: ' + process.env.PREFIX + 'carreport [spawncode] [issue]');
    }
    let spawncode = params[0];
    let issue = params.slice(1).join(' ');
    let reporter = message.author.id;

    fivemexports.gmt.execute("SELECT user_id FROM gmt_verification WHERE discord_id = ?", [reporter], (userResult) => {
        if (!userResult || userResult.length === 0) {
            return message.reply('You do not have a Perm ID linked to your Discord account.');
        }
        let userId = userResult[0].user_id;
        fivemexports.gmt.execute("SELECT * FROM gmt_user_vehicles WHERE user_id = ? AND vehicle = ?", [userId, spawncode], (vehicleResult) => {
            if (!vehicleResult || vehicleResult.length === 0) {
                return message.reply('You do not own this vehicle.');
            }
            fivemexports.gmt.execute("INSERT INTO cardev (spawncode, issue, reporter, claimed, completed, notes) VALUES(?, ?, ?, ?, ?, ?)", [spawncode, issue, reporter, false, false, ""], (insertResult) => {
                fivemexports.gmt.execute("SELECT * FROM cardev WHERE reporter = ? AND spawncode = ? AND issue = ?", [reporter, spawncode, issue], (reportResult) => {
                    if (!reportResult || reportResult.length === 0) {
                        return message.reply('There was an error submitting your report. Please try again.');
                    }

                    let embed = {
                        "title": "Car Report Submitted",
                        "description": `Spawn Code: **${spawncode}**\nIssue: **${issue}**\nReporter: **<@${reporter}>**\nReport ID: **${reportResult[0].reportid}**\n`, // serio is the best sigma
                        "color": settingsjson.settings.botColour,
                        "footer": {
                            "text": ""
                        },
                        "timestamp": new Date()
                    };
                    message.channel.send({ embed });

                    let logsEmbed = new MessageBuilder()
                        .setTitle('Car Report Received')
                        .setDescription(`Spawn Code: **${spawncode}**\nIssue: **${issue}**\nReporter: **<@${reporter}>**\nReport ID: **${reportResult[0].reportid}**\n`)
                        .setColor(settingsjson.settings.botColour)
                        .setFooter('GMT')
                        .setTimestamp();

                    let hook = new Webhook(settingsjson.settings.carReportWebhook);
                    hook.send(logsEmbed);
                });
            });
        });
    });
};

exports.conf = {
    name: "carreport",
    perm: 0,
    guild: "1304983538071896165"
};