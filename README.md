Trackpad
========

Use your Iphone or Android as a trackpad for your Mac/PC. Make your smartphone smarter.

Implementation Logic: 
Phone client:
1. When phone client starts, listen to UDP port.
2. When accept UDP, save server IP to server list.
3. Clean not active server ip. If can not receive udp from the server for a long time, we define it inactive. This is to make sure connect to valid server.
4. When user select Server IP from list, or program gets first UDP IP, connect to the server. Of course the previous connection will disconnect. If you would like to control multiple computers using one phone, you can do it with little modification.


PC/Mac client:
1. When program starts, broadcast UDP to intranet every some time, at the same time setup TCP listener.
2. Accept any TCP request. This means, you can use more than one phone to control your computer at same time.
3. Use menu bar to start or stop pc client.
