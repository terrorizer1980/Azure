#!/usr/bin/env node
const { writeFileSync, existsSync, readFileSync } = require("fs");
const { resolve } = require("path");
const docker_config = resolve("/docker_data", "AzureConfig.json")

var configOld = {
    "world": "Is Core",
    "description": "A simple description to not disturb the reading",
    "gamemode": "survival",
    "difficulty": "normal",
    "players": "13",
    "platform": "bedrock",
    "version": "latest"
}

if (existsSync("/etc/bdscoreConfig")) {
    const Portal = JSON.parse(readFileSync("/etc/bdscoreConfig", "utf8"))
    configOld.description = Portal.worlddescripition
    configOld.world = Portal.worldname
    configOld.players = Portal.totalplayers
    configOld.gamemode = Portal.gamemode
    configOld.difficulty = Portal.difficulty
    configOld.platform = Portal.bdsplatfrom
    writeFileSync(docker_config, JSON.stringify(configOld, null, 4));
}