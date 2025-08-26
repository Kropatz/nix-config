#!/usr/bin/env node
import { exec } from 'child_process';

async function execCommand(command) {
  console.log(`Executing command: ${command}`);
  return new Promise((resolve, reject) => {

    let child = exec(command);
    let stdoutData = '';
    child.stdout.on('data', (data) => {
      stdoutData += data;
      process.stdout.write(data.toString());
    });
    child.stderr.on('data', (data) => {
      process.stderr.write(data.toString());
    });
    child.on('close', (code) => {
      if (code !== 0) {
        reject(new Error(`Command failed with exit code ${code}`));
      } else {
        resolve(stdoutData.trim());
      }
    });
    child.on('error', (err) => {
      reject(err);
    });
  });
}

/** @type(String) */
let monitors = {};
let result = await execCommand('hyprctl -j monitors all');
result = JSON.parse(result);
result.forEach(monitor => {
  monitors[monitor.name] = {
    name: monitor.name,
    availableModes: monitor.availableModes
  };
});
console.log(monitors);
let zenity_monitors = Object.keys(monitors).join(' \\\n');
let selectedMonitor = await execCommand(`zenity --list --title "Choose a monitor" \
 --column="Name" \
 ${zenity_monitors}`);


let zenity_modes = monitors[selectedMonitor].availableModes.join(' \\\n');
let selectedMode = await execCommand(`zenity --list --title "Choose a mode" \
 --column="Mode" \
 ${zenity_modes}`);

console.log(`monitor = ${selectedMonitor}, ${selectedMode}, auto, auto`);

let mirror = false;
try {
  await execCommand(`zenity --question --text="Do you want to mirror to this display?"`);
  mirror = true;
} catch (e) {
}
if (mirror) {
  let otherMonitor = Object.keys(monitors).filter(m => m !== selectedMonitor);
  await execCommand(`hyprctl keyword monitor "${selectedMonitor}, ${selectedMode},auto,auto,mirror,${otherMonitor}"`);
} else {
  await execCommand(`hyprctl keyword monitor "${selectedMonitor}, ${selectedMode}, auto, auto"`);
}
