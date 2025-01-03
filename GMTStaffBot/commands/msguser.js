const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0] || !parseInt(params[0])) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage: " + process.env.PREFIX + '\n`!dm [user_id] [message]`',
            "color": 0x57F288,
        };
        return message.channel.send({ embed });
    }

    const userID = params[0];

    // Fetch admin's user ID based on message author's Discord ID
    fivemexports.gmt.execute("SELECT user_id FROM `gmt_verification` WHERE discord_id = ?", [message.author.id], (adminResult) => {
        if (adminResult.length > 0) {
            const adminPermid = adminResult[0].user_id;

            fivemexports.gmt.execute("SELECT discord_id, user_id FROM `gmt_verification` WHERE user_id = ?", [userID], (result) => {
                if (result.length > 0) {
                    const discordID = result[0].discord_id;

                    fivemexports.gmt.execute("SELECT * FROM `gmt_users` WHERE id = ?", [adminPermid], (adminFetchResult) => {
                        if (adminFetchResult.length > 0) {
                            const adminName = adminFetchResult[0].username;
                            const messageContent = params.slice(1).join(' ');

                            const targetUser = client.users.get(discordID);

                            if (targetUser) {
                                let dmEmbed = {
                                    "title": "Message From GMT Staff Member",
                                    "description": `**Staff Member:** ${adminName}\n\n**Message:**\n${messageContent}`,
                                    "color": settingsjson.settings.botColour,
                                    "footer": {
                                        "text": "Sent by " + message.author.tag,
                                    },
                                    "timestamp": new Date()
                                };

                                targetUser.send({ embed: dmEmbed })
                                    .then(() => {
                                        let embed = {
                                            "title": "Message Sent",
                                            "description": `Message sent to user with Discord ID ${discordID}.`,
                                            "color": settingsjson.settings.botColour,
                                        };
                                        message.channel.send({ embed });
                                    })
                                    .catch(error => {
                                        console.error(error);
                                        let embed = {
                                            "title": "Error",
                                            "description": "An error occurred while sending the message.",
                                            "color": 0x57F288,
                                        };
                                        message.channel.send({ embed });
                                    });
                            } else {
                                let embed = {
                                    "title": "User Not Found",
                                    "description": `User with Discord ID ${discordID} not found.`,
                                    "color": 0x57F288,
                                };
                                message.channel.send({ embed });
                            }
                        } else {
                            let embed = {
                                "title": "Admin Not Found",
                                "description": "No admin found for the provided admin user ID.",
                                "color": 0x57F288,
                            };
                            message.channel.send({ embed });
                        }
                    });
                } else {
                    let embed = {
                        "title": "User Not Found",
                        "description": `No Discord ID found for the provided User ID.`,
                        "color": 0x57F288,
                    };
                    message.channel.send({ embed });
                }
            });
        } else {
            let embed = {
                "title": "Admin Not Found",
                "description": "No admin found for the provided message author's Discord ID.",
                "color": 0x57F288,
            };
            message.channel.send({ embed });
        }
    });
};

exports.conf = {
    name: "dm",
    perm: 9,
    guild: "1304983538071896165" // Replace with your actual guild ID
};
