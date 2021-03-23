#!/usr/bin/env node
const express = require("express");
const { readFileSync, writeFileSync } = require("fs");
const { resolve } = require("path");
var cors = require("cors");
const bodyParser = require("body-parser");
var fetch = require("node-fetch")
const docker_config = resolve("/docker_data", "AzureConfig.json")
fetch("https://api.ipify.org/?format=json").then(response => response.json()).then(json_req => {
    const ip = json_req.ip;
    const app = express();
    app.use(cors());
    app.use(bodyParser.json());
    app.use(bodyParser.urlencoded({ extended: true }));
    app.get("/", (req, res) => {
        var config = readFileSync(resolve(__dirname, "index.html")).toString();
        return res.send(config);
    });
    app.get("/save", (req, res) => {
        const config_json = JSON.stringify(req.query, null, 4)
        writeFileSync(docker_config, config_json)
        res.send({
            "A_message": "You can connect to the virtual machine and change the settings in the file: /docker_data/AzureConfig.json",
            ...req.query
        })
        process.exit(1)
    })
    const port = (7774)
    app.listen(port, function (){
        console.log(`Config: http://${ip}:${port}`);
    });
})