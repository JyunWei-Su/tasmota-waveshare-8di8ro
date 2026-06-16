# tasmota-waveshare-8di8ro

Custom-compiled [Tasmota](https://tasmota.github.io/) firmware for:

| Board | Part no. |
|-------|----------|
| Waveshare ESP32-S3-ETH-8DI-8RO | standard Ethernet |
| Waveshare ESP32-S3-POE-ETH-8DI-8RO | Power-over-Ethernet |

Both variants use **identical firmware** - the only hardware difference is the PoE module.

---

## What's included

| File | Purpose |
|------|---------|
| `user_config_override.h` | Compile-time Tasmota features for this board |
| `platformio_override.ini` | PlatformIO environment (`tasmota32s3-waveshare`) |
| `tca9554.dat` | TCA9554 relay mapping - upload to Tasmota file system |
| `.github/workflows/auto-build.yml` | Weekly release automation |

---

## Releases

The [Actions workflow](.github/workflows/auto-build.yml) checks for new upstream Tasmota releases every Monday at 03:00 UTC. When a new version is found, it compiles the Waveshare ESP32-S3 build and publishes a [GitHub Release](../../releases):

| Binary | Notes |
|--------|-------|
| `tasmota32s3-waveshare-8di8ro-*.bin` | Standard build |
| `tasmota32s3-waveshare-8di8ro-*.factory.bin` | Factory image for initial serial flashing |
| `tasmota32s3-safeboot-waveshare-8di8ro-*.bin` | Safeboot for standard build |
| `tasmota32s3-waveshare-8di8ro-*.manifest.json` | ESP Web Tools manifest for browser flashing |
| `tasmota32s3-waveshare-8di8ro-*.install.html` | Standalone ESP Web Tools installer page |
| `tca9554.dat` | TCA9554 relay mapping file |

---

## Flashing

### Initial flash (esptool)
```bash
# Flash factory image
esptool.py --chip esp32s3 write_flash 0x0 tasmota32s3-waveshare-8di8ro-*.factory.bin
```

### Initial flash (browser)
Use the release `.install.html` page, or use [Tasmota Web Installer](https://tasmota.github.io/install/) and its **Upload factory.bin** button to select the downloaded `.factory.bin` file locally.

Do not paste the GitHub release asset URL into the Tasmota installer. URL-based flashing should use the release `.manifest.json` file through ESP Web Tools.

### Update via OTA
Upload `tasmota32s3-waveshare-8di8ro-*.bin` through **Tasmota web UI -> Firmware Upgrade**.

---

## First-boot setup

Paste each command into **Consoles -> Console**:

```
# 1. Apply template
Template {"NAME":"ESP32S3-POE-ETH-8DI-8RO","GPIO":[40,1,1,1,32,33,34,35,36,37,38,39,5600,704,672,736,5568,1,1,1,1,1,0,0,0,0,0,1376,1,1,608,640,1,1,8864,480,8800,8832],"FLAG":0,"BASE":1}
Module 0

# 2. Enable W5500 Ethernet
EthType 8

# 3. Map TCA9554 relays  (run AFTER uploading tca9554.dat via File System)
Rule3 on file#tca9554.dat do {"NAME":"TCA9554","GPIO":[224,225,226,227,228,229,230,231]} endon
Rule3 1

# 4. (Optional) Decouple digital inputs from relays
SetOption73 1

# 5. (Optional) Correct WS2812 colour channel order
SetOption37 24

# 6. (Optional) Enable PWM buzzer
BuzzerPwm 1
```

After `Module 0`, Tasmota restarts. Reconnect, then run the remaining commands.

Upload `tca9554.dat` via **Consoles -> Manage File System** before enabling Rule3.

---

## Board specs

| Feature | Detail |
|---------|--------|
| MCU | ESP32-S3-WROOM-1U-N16R8 (16 MB Flash, 8 MB OPI PSRAM) |
| Ethernet | W5500 SPI - CLK:GPIO15 MOSI:GPIO13 MISO:GPIO14 CS:GPIO16 INT:GPIO12 |
| I2C | SCL:GPIO41 SDA:GPIO42 |
| Relay expander | TCA9554 @ 0x20 (8 relays, COM+NO+NC, <=10 A 250 VAC) |
| Digital inputs | GPIO4-GPIO11 (optocoupler-isolated, active-low) |
| RTC | PCF85063 @ 0x51 |
| RGB LED | WS2812 on GPIO38 |
| Buzzer | GPIO46 (PWM) |
| RS-485 | TX:GPIO17 RX:GPIO18 |
| Power | 7-36 V DC screw terminal **or** USB-C (5 V) |
| PoE | 802.3af/at on POE variant |

---

## Local build

```bash
git clone https://github.com/arendst/Tasmota.git
cd Tasmota
cp /path/to/this/repo/user_config_override.h  tasmota/user_config_override.h
cp /path/to/this/repo/platformio_override.ini  platformio_override.ini
pip install pioarduino
platformio run -e tasmota32s3-waveshare
```

---

## Credits

- Template and TCA9554 driver by [@arendst](https://github.com/arendst) - [Tasmota discussion #24205](https://github.com/arendst/Tasmota/discussions/24205)
- ESPHome pin map: [devices.esphome.io](https://devices.esphome.io/devices/waveshare-esp32-s3-eth-8di-8ro/)
