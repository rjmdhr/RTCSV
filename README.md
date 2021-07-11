# RTCSV
A Real Time Clock in System Verilog, that drives 6 seven segment displays. Initially it was meant to help verify a PCB version with basic CMOS counters and logic gate ICs but due to design differences the idea was scraped.

## Waveforms
### Seven Segment Displays
![sevseg_waveforms](https://user-images.githubusercontent.com/18176285/125177268-6c243680-e1a8-11eb-9d68-a3f980c3b330.png)
### Clock Counters (20:57:00 to 00:00:00)
![clock_waveforms](https://user-images.githubusercontent.com/18176285/125177313-c0c7b180-e1a8-11eb-82ba-2093c2229f6c.png)
### Shift Register Debouncers for Manual Input
![debounce_waveforms](https://user-images.githubusercontent.com/18176285/125177328-df2dad00-e1a8-11eb-8c4a-9c9d4b3a1e7a.png)
### Manual Input
![manual_waveforms](https://user-images.githubusercontent.com/18176285/125177338-f66c9a80-e1a8-11eb-9361-37e26f5d810f.png)

## Improvements
- Turn displays off when unecessary (08:30:57 should be 8:30:57)
- Add ability to decrease digits in manual mode
- Automatically set the actual time via a compatible communications interface through an external module
