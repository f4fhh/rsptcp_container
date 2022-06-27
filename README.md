# rsptcp_container
Docker container for rsp_tcp, a linux I/Q stream server for SDRPlay RSP1, RSP1A, RSP2, RSPDuo, RSPdx

It works with compatible devices including:
* RSP1, RSP1A, RSP2, RSPDuo, RSPdx SDRPlay devices

### Defaults
* Port 1234/tcp is used for the I/Q data stream and is exposed by default

### User Configured Environment Variables

#### Example docker run

```
docker run -d \
--restart unless-stopped \
--name='rsptcp' \
--device=/dev/bus/usb \
ghcr.io/f4fhh/rsptcp_container
```
### HISTORY
 - Version 0.1.0: Initial build

### Credits
 - [SDRPlay](https://github.com/SDRplay) for the SDK of the RSP devices
