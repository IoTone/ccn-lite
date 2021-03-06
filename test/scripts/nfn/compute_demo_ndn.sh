#!/bin/bash

killall ccn-lite-relay
killall ccn-nfn-relay
killall python

echo "starting relays"

$CCNL_HOME/bin/ccn-nfn-relay -v 99 -u 9000 -x /tmp/mgmt1.sock 2> /tmp/r0.log &
$CCNL_HOME/bin/ccn-nfn-relay -v 99 -u 9001 -x /tmp/mgmt2.sock 2> /tmp/r1.log &

sleep 3
echo "adding new faces"

$CCNL_HOME/bin/ccn-lite-ctrl -x /tmp/mgmt1.sock newUDPface any 127.0.0.1 9001  | $CCNL_HOME/bin/ccn-lite-ccnb2xml
$CCNL_HOME/bin/ccn-lite-ctrl -x /tmp/mgmt2.sock newUDPface any 127.0.0.1 9002  | $CCNL_HOME/bin/ccn-lite-ccnb2xml

sleep 3
echo "adding forwarding rules"

$CCNL_HOME/bin/ccn-lite-ctrl -x /tmp/mgmt1.sock prefixreg /test 2 ndn2013 | $CCNL_HOME/bin/ccn-lite-ccnb2xml
$CCNL_HOME/bin/ccn-lite-ctrl -x /tmp/mgmt2.sock prefixreg /COMPUTE 2 ndn2013 | $CCNL_HOME/bin/ccn-lite-ccnb2xml

sleep 3
echo "adding content"

$CCNL_HOME/bin/ccn-lite-ctrl -x /tmp/mgmt2.sock addContentToCache $CCNL_HOME/test/ndntlv/nfn/computation_content.ndntlv | $CCNL_HOME/bin/ccn-lite-ccnb2xml

sleep 3

python $CCNL_HOME/test/scripts/nfn/dummyanswer_ndn.py & > /dev/null

sleep 3

$CCNL_HOME/bin/ccn-lite-peek -s ndn2013 -u 127.0.0.1/9000 -w 100 "" "call 1 /test/data" | $CCNL_HOME/bin/ccn-lite-pktdump

