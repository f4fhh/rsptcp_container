#!/bin/bash
/usr/bin/sdrplay_apiService &
sleep 1
/usr/bin/rsp_tcp $* &
wait -n
exit $?