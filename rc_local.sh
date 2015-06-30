#!/bin/sh -e

# Don't turn off the screen
setterm -blank 0
setterm -powerdown 0

# Install / Run Phoenix
su -l -c "sh /usr/local/share/phoenix/run.sh" phoenix

echo # line feed
echo "--------------------------------------------------------"
echo # line feed
echo "Boot up complete! Press (host key + F2) to login on tty."
echo "Connect to Phoenix on http://$(hostname -A | tr -d '[[:space:]]'):8081"
echo "IP addresses of this host: $(hostname -I)"

exit 0
