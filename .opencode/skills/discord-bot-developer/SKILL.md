---
name: discord-bot-developer
description: "Expert Discord bot development using Discord.js, slash commands, and server integrations"
---

# Discord Bot Developer

## Overview

Build Discord bots for moderation, entertainment, and community management.

## When to Use This Skill

- Use when building Discord bots
- Use when creating community tools

## How It Works

### Step 1: Bot Setup

```markdown
## Create Discord Application
1. Go to discord.com/developers/applications
2. Create New Application
3. Go to Bot → Add Bot
4. Copy Token (keep secret!)
5. Enable Intents:
   - Presence Intent
   - Server Members Intent
   - Message Content Intent
```

### Step 2: Basic Bot (Discord.js v14)

```javascript
const { Client, GatewayIntentBits, Events } = require('discord.js');

const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent,
    GatewayIntentBits.GuildMembers
  ]
});

client.once(Events.ClientReady, () => {
  console.log(`Logged in as ${client.user.tag}`);
});

client.on(Events.MessageCreate, async (message) => {
  if (message.author.bot) return;
  
  if (message.content === '!ping') {
    await message.reply('Pong! 🏓');
  }
});

client.login(process.env.DISCORD_TOKEN);
```

### Step 3: Slash Commands

```javascript
const { SlashCommandBuilder, REST, Routes } = require('discord.js');

// Define commands
const commands = [
  new SlashCommandBuilder()
    .setName('ping')
    .setDescription('Check bot latency'),
  
  new SlashCommandBuilder()
    .setName('userinfo')
    .setDescription('Get user information')
    .addUserOption(option =>
      option.setName('user')
        .setDescription('The user')
        .setRequired(false)
    )
].map(cmd => cmd.toJSON());

// Register commands
const rest = new REST({ version: '10' }).setToken(process.env.DISCORD_TOKEN);

await rest.put(
  Routes.applicationGuildCommands(CLIENT_ID, GUILD_ID),
  { body: commands }
);

// Handle commands
client.on(Events.InteractionCreate, async (interaction) => {
  if (!interaction.isChatInputCommand()) return;
  
  if (interaction.commandName === 'ping') {
    await interaction.reply(`Pong! ${client.ws.ping}ms`);
  }
  
  if (interaction.commandName === 'userinfo') {
    const user = interaction.options.getUser('user') || interaction.user;
    await interaction.reply(`Username: ${user.username}\nID: ${user.id}`);
  }
});
```

### Step 4: Embeds & Components

```javascript
const { EmbedBuilder, ActionRowBuilder, ButtonBuilder, ButtonStyle } = require('discord.js');

// Create embed
const embed = new EmbedBuilder()
  .setColor(0x5865F2)
  .setTitle('Welcome!')
  .setDescription('Welcome to the server!')
  .addFields(
    { name: 'Rules', value: 'Read #rules', inline: true },
    { name: 'Help', value: 'Ask in #help', inline: true }
  )
  .setTimestamp();

// Create buttons
const row = new ActionRowBuilder()
  .addComponents(
    new ButtonBuilder()
      .setCustomId('accept_rules')
      .setLabel('Accept Rules')
      .setStyle(ButtonStyle.Success),
    new ButtonBuilder()
      .setCustomId('get_roles')
      .setLabel('Get Roles')
      .setStyle(ButtonStyle.Primary)
  );

await channel.send({ embeds: [embed], components: [row] });

// Handle button clicks
client.on(Events.InteractionCreate, async (interaction) => {
  if (!interaction.isButton()) return;
  
  if (interaction.customId === 'accept_rules') {
    const role = interaction.guild.roles.cache.find(r => r.name === 'Member');
    await interaction.member.roles.add(role);
    await interaction.reply({ content: 'Rules accepted!', ephemeral: true });
  }
});
```

## Best Practices

- ✅ Use slash commands (not prefix)
- ✅ Handle errors gracefully
- ✅ Respect rate limits
- ❌ Don't store tokens in code
- ❌ Don't ignore permissions

## Related Skills

- `@chatbot-developer`
- `@senior-nodejs-developer`
