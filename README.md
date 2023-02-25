# pico-tiny-starter-kit
Project configured for using Raspberry Pi's [Pico SDK](https://github.com/raspberrypi/pico-sdk) with [tiny](https://github.com/ryanplusplus/tiny).

## Usage
### Build
```shell
make
```

### Clean
```shell
make clean
```

### Upload
```shell
make jlink-upload
```

```shell
make openocd-upload
```

```shell
make ufs-upload
```

### Erase
```shell
make jlink-erase
```

### Test
```shell
make test
```

## Resources
- [RP2040 Datasheet](https://datasheets.raspberrypi.org/rp2040/rp2040-datasheet.pdf)
- [Pico Datasheet](https://datasheets.raspberrypi.org/pico/pico-datasheet.pdf)
- [Pico C/C++ SDK](https://datasheets.raspberrypi.org/pico/raspberry-pi-pico-c-sdk.pdf)
