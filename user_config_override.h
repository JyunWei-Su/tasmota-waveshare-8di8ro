/*
  user_config_override.h  –  Tasmota custom build config
  Target : Waveshare ESP32-S3-ETH-8DI-8RO
           Waveshare ESP32-S3-POE-ETH-8DI-8RO  (same firmware)

  MCU  : ESP32-S3-WROOM-1U-N16R8 (16 MB Flash, 8 MB OPI PSRAM)

  Pin map (confirmed by Tasmota maintainer @arendst, Dec 2025)
  ─────────────────────────────────────────────────────────────
  W5500 SPI Ethernet
    CLK   = GPIO15     MOSI  = GPIO13
    MISO  = GPIO14     CS    = GPIO16
    INT   = GPIO12

  I2C (Bus 1)
    SCL   = GPIO41     SDA   = GPIO42

  I2C devices
    TCA9554 relay expander  @ 0x20  (8 relays via I/O expander)
    PCF85063 RTC            @ 0x51

  Digital Inputs (optocoupler-isolated, active-low)
    DI1-DI8 = GPIO4 ... GPIO11

  WS2812 RGB LED = GPIO38
  Buzzer (PWM)   = GPIO46  (strapping pin, use BuzzerPwm 1)
  RS-485 TX      = GPIO17  RX = GPIO18

  =====================================================================
  FIRST-BOOT CONSOLE COMMANDS  (run once after flashing)
  =====================================================================

  1. Apply board template:
       Template {"NAME":"ESP32S3-POE-ETH-8DI-8RO","GPIO":[40,1,1,1,32,33,34,35,36,37,38,39,5600,704,672,736,5568,1,1,1,1,1,0,0,0,0,0,1376,1,1,608,640,1,1,8864,480,8800,8832],"FLAG":0,"BASE":1}
       Module 0

  2. Enable W5500 Ethernet:
       EthType 8

  3. Map TCA9554 relays (Rule 3):
       Rule3 on file#tca9554.dat do {"NAME":"TCA9554","GPIO":[224,225,226,227,228,229,230,231]} endon
       Rule3 1

  4. (Optional) Decouple inputs from relays:
       SetOption73 1

  5. (Optional) Fix WS2812 channel order:
       SetOption37 24

  6. (Optional) Enable buzzer in PWM mode:
       BuzzerPwm 1
*/

#ifndef _USER_CONFIG_OVERRIDE_H_
#define _USER_CONFIG_OVERRIDE_H_

// --- I2C ---------------------------------------------------------------
#ifndef USE_I2C
  #define USE_I2C
#endif

// --- TCA9554 I2C relay expander (addr 0x20) ----------------------------
// PCF8574 and PCA9557 share the same I2C address range; disable them.
#ifdef USE_PCF8574
  #undef USE_PCF8574
#endif
#ifdef USE_PCA9557
  #undef USE_PCA9557
#endif
#define USE_TCA9554

// --- RTC (PCF85063 @ 0x51) --------------------------------------------
#define USE_RTC_CHIPS
#define USE_PCF85063

// --- W5500 SPI Ethernet -----------------------------------------------
#ifndef USE_ETHERNET
  #define USE_ETHERNET
#endif

// --- WS2812 addressable RGB LED ---------------------------------------
#ifndef USE_WS2812
  #define USE_WS2812
#endif

// --- Buzzer -----------------------------------------------------------
#ifndef USE_BUZZER
  #define USE_BUZZER
#endif

// --- RS-485 / Modbus bridge (uncomment if needed) ---------------------
// #define USE_MODBUS_BRIDGE
// #define USE_MODBUS_BRIDGE_TCP

#endif  // _USER_CONFIG_OVERRIDE_H_
