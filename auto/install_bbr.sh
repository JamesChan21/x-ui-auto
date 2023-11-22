#!/usr/bin/expect

set timeout -1
spawn ./bbr.sh
expect "Press any key to start...or Press Ctrl+C to cancel"
send "\r"
expect "*restart*"
send "y\r"
expect eof
