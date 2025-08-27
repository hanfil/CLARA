sudo mkdir /opt/zeek
sudo mkdir /opt/zeek/logs
sudo mkdir /opt/zeek/scripts
sudo cat > /opt/zeek/scripts/local.zeek << EOF
@load policy/tuning/json-logs.zeek
@load base/frameworks/logging
@load base/frameworks/packet-filter

redef Log::default_logdir = "/opt/zeek/logs";

# Disable any BPF-based auto-protocol filters including default BPF
redef PacketFilter::default_capture_filter = "";

# Hook to filter reporter.log entries
hook Log::log_stream_policy(rec: any, id: Log::ID)
{
    if ( id == Reporter::LOG )
    {
        local r = rec as Reporter::Info;
        # Filter out nfqueue "Resource temporarily unavailable" errors
        if ( /failed to read a packet from nfqueue.*Resource temporarily unavailable/ in r$message )
            break;
    }
}
EOF