const Commando = require('discord.js-commando');
const request = require('request');

module.exports = class SVCommands extends Commando.Command {
    constructor(client) {
        super(client, {
            name: "sv",
            group: "card_games",
            memberName: "sv",
            description: "Looks up Shadowverse card information.",
            examples: ["sv Water Fairy"],

            args: [
                {
                    key: 'card',
                    label: 'card',
                    prompt: 'what card do you want to look up?',
                    type: 'string'
                }
            ]
        })
    }

    async run(msg, args, client){
        let card = args.card;

        request('https://shadowverse-portal.com/api/v1/cards?format=json&lang=en', function(error, response, body) {
            if (!error && response.statusCode == 200) { 
                let data = JSON.parse(body);
                
                for (let i = 0; i < data['data']['cards'].length; i++){
                    if (data['data']['cards'][i]['card_name'].toLowerCase() == card.toLowerCase()){
                        var cardInfo = data['data']['cards'][i];
                        break;
                    }
                }

                if (typeof cardInfo != 'undefined') {
                    return msg.reply("", {embed: {
                        color: 3447003,
                        title: `Shadowverse`,
                        url: "https://shadowverse.com",
                        thumbnail: {
                            url: `https://shadowverse-portal.com/image/card/en/C_${cardInfo['card_id']}.png`
                        },
                        fields: [{
                            name: "Stats",
                            value: `**Name:** ${cardInfo['card_name']}\n**Cost:** ${cardInfo['cost']} PP\n**Attack / Defense:** ${cardInfo['atk']}/${cardInfo['life']}\n**Evo Attack / Defense:** ${cardInfo['evo_atk']}/${cardInfo['evo_life']}`,
                            inline: true
                        },
                        {
                            name: "Skills",
                            value: `**Skill:** ${cardInfo['skill_disc']}\n**Evo Skill:** ${cardInfo['evo_skill_disc']}`
                        },
                        {
                            name: "Lore",
                            value: `**Description:** ${cardInfo['description']}\n**Evo Description:** ${cardInfo['evo_description']}\n**Tribe:** ${cardInfo['tribe_name']}`
                        },
                        {
                            name: "Art",
                            value: `[Classic](https://shadowverse-portal.com/image/card/en/C_${cardInfo['card_id']}.png) - [Evolved](https://shadowverse-portal.com/image/card/en/E_${cardInfo['card_id']}.png)`
                        }]
                    }});
                }
                else {
                    return msg.reply(`\`${card}\` did not match any cards. Please try again.`)
                }
            }
        })
    }
}