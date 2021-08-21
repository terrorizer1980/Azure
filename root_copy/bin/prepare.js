#!/usr/bin/env node
const child_process = require("child_process");
const fs = require("fs");
const path = require("path");

let VMConfig = {
    world: "The Docker Dockered",
    description: "The Docker Dockered",
    gamemode: "survival",
    difficulty: "normal",
    players: 1,
    platform: "bedrock",
    dockertag: "latest"
}

if (fs.existsSync("/etc/VMAzureConfig.json")) VMConfig = JSON.parse(fs.readFileSync("/etc/VMAzureConfig.json", "utf8"));

// Create Disk to Save Data
function CreateDiskPartion(){
    return new Promise((resolve, reject) => {
        const disks = fs.readdirSync("/dev").filter(a => /^sd/g.test(a));
        const disk_in_use = disks.filter(a => /[0-9]$/g.test(a)).map(b => b.replace(/[0-9]$/g, "")).filter(function(item, pos, self) {return self.indexOf(item) == pos;});
        const disk_free = disks.filter(a => !/[0-9]$/g.test(a)).filter(a => !disk_in_use.includes(a)).map(b => path.join("/dev", b));
        if (disk_free.length > 0) {
            const disk = disk_free[0];
            child_process.exec(`parted -s ${disk} mklabel msdos mkpart primary ext4 0% 100%`, (err, stdout, stderr) => {
                if (err) return reject(err);
                child_process.exec(`mkfs.ext4 ${disk}1`, (err, stdout, stderr) => {
                    if (err) return reject(err);
                    const disk_uuid = child_process.execSync(`blkid ${disk}1`).toString().replace(/^.*:\sUUID="|"\sTYPE=".*PARTUUID.*"|\n/g, "");
                    const fstab = fs.readFileSync("/etc/fstab", "utf8").split(/\n|\t/gi).map(a => a.trim()).filter(a => /^#/gi.test(a) || a.length > 0).map(mount_point => {
                        const Split = mount_point.split(/\s+/gi);
                        return {
                            device: Split[0],
                            mount_point: Split[1],
                            fs_type: Split[2],
                            options: Split[3],
                            dump: parseInt(Split[4]),
                            pass: parseInt(Split[5]),
                        }
                    });
                    const disk_mount = `UUID=${disk_uuid} /docker_data/ ext4 defaults 0 ${fstab[fstab.length - 1].pass + 1}`;
                    fs.appendFileSync("/etc/fstab", `\n${disk_mount}\n`);
                    child_process.execSync("mount -a")
                    resolve(disk);
                });
            });
        } else {
            reject("No Free Disks");
        }
    });
}

// Start Docker Image
function StartBdsCore(){
    const args = [];

    if (VMConfig.world) args.push("-e", `WORLD_NAME="${VMConfig.world}"`);
    if (VMConfig.description) args.push("-e", `DESCRIPTION="${VMConfig.description}"`);
    if (VMConfig.gamemode) args.push("-e", `GAMEMODE="${VMConfig.gamemode}"`);
    if (VMConfig.difficulty) args.push("-e", `DIFFICULTY="${VMConfig.difficulty}"`);
    if (VMConfig.players) args.push("-e", `PLAYERS="${VMConfig.players}"`);
    if (VMConfig.platform) args.push("-e", `SERVER="${VMConfig.platform}"`);

    return child_process.execFileSync("docker", [
        "run",
        "--rm",
        "-d",
        "--name", "BdsCore",
        "--network=host",
        "-v", "/docker_data/:/root/bds_core",
        ...args,
        `ghcr.io/the-bds-maneger/core:${VMConfig.dockertag || "latest"}`
    ]);
}

// Check Docker Update Image
function CheckDockerImage(){
    const Status = child_process.execSync(`docker pull ghcr.io/the-bds-maneger/core:${VMConfig.dockertag || "latest"}`).toString();
    if (!(Status.includes("up to date"))) {
        child_process.execSync("docker stop BdsCore");
        // Check Space avaible
        const DiskSpace = parseInt(child_process.execSync(`df -h / | grep /dev/ | awk '{print $5}'`).toString().replace(/\s|%/g, ""));
        if (DiskSpace => 70) {
            const DockerImageID = child_process.execSync("docker images").toString().split(/\n/gi).filter(a => /<none>.*<none>.*/gi.test(a)).map(a => a.split(/\s+/gi)[2]);
            for (let DockerID of DockerImageID) child_process.execSync(`docker rmi -f ${DockerID}`);
        }
    }
}

// Check BdsCore is Running
function CheckBdsCore(){
    return new Promise((resolve, reject) => {
        child_process.exec("docker ps", (err, stdout, stderr) => {
            if (err) return reject(err);
            const BdsCore = (stdout+stderr).split(/\n/gi).filter(a => /BdsCore/gi.test(a));
            if (BdsCore.length > 0) {
                resolve(true);
            } else {
                resolve(false);
            }
        });
    });
}

(async () => {
    if (child_process.execSync("lsblk").toString().includes("docker_data")) {
        if (child_process.execSync("docker ps -a").toString().includes("BdsCore")) console.log("BdsCore is already running");
        else StartBdsCore();
    } else {
        console.log("Creating Bds Core Save partition");
        await CreateDiskPartion();
        StartBdsCore();
    }
    setInterval(() => {
        CheckDockerImage();
        CheckBdsCore().then(BdsCore => {
            if (BdsCore) {
                console.log("BdsCore is running");
            } else {
                console.log("BdsCore is not running");
                StartBdsCore();
            }
        }).catch(err => {
            console.log(err);
        });
    }, 1000);
})();