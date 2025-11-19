import os
import re

def main():
    proxies_file = '/config/proxies.txt'
    proxy3_conf_file = '/usr/local/3proxy/conf/3proxy.cfg'
    base_listen_port = 10001

    if not os.path.exists(proxies_file):
        print(f"Error: {proxies_file} not found!")
        exit(1)

    with open(proxies_file, 'r') as f:
        proxies = [line.strip() for line in f if line.strip() and not line.startswith('#')]

    # 3proxy configuration header
    conf_parts = [
        '# 3proxy configuration file',
        '# DNS servers',
        'nserver 8.8.8.8',
        'nserver 8.8.4.4',
        'nserver 1.1.1.1',
        '',
        '# Timeouts',
        'timeouts 1 5 30 60 180 1800 15 60',
        '',
        '# Logging (to stdout for Docker)',
        'log /dev/stdout',
        'flush',
        '',
        '# Authentication & ACL (allow all - traffic already restricted by internal network)',
        'auth none',
        'allow * * *',
        ''
    ]

    valid_proxies = []

    for i, proxy_line in enumerate(proxies):
        listen_port = base_listen_port + i

        # Parse proxy_line (supports http/https/socks5)
        # Format: http://user:pass@host:port or http://host:port or host:port (defaults to http)
        match = re.match(r'(?:(?P<protocol>https?|socks5)://)?(?:(?P<user>[^:]+):(?P<pass>[^@]+)@)?(?P<host>[^:]+):(?P<port>\d+)', proxy_line)
        if not match:
            print(f"Warning: Skipping invalid proxy format: {proxy_line}")
            continue
        
        parts = match.groupdict()
        protocol = parts.get('protocol') or 'http'  # Default to http if not specified
        host = parts['host']
        port = parts['port']
        user = parts.get('user')
        password = parts.get('pass')

        # Map protocol to 3proxy parent type keyword
        if protocol == 'http':
            parent_type = 'http'
        elif protocol == 'https':
            parent_type = 'https'
        elif protocol == 'socks5':
            parent_type = 'socks5'
        else:
            print(f"Warning: Unsupported protocol {protocol} for proxy {proxy_line}")
            continue

        # Build parent directive
        # Format: parent <type> <host> <port> [username] [password]
        parent_line = f'parent {parent_type} {host} {port} 1'
        if user and password:
            parent_line += f' {user} {password}'

        # Add proxy configuration
        conf_parts.append(f'# --- Proxy {i + 1}: {protocol.upper()} {host}:{port} on gateway port {listen_port} ---')
        conf_parts.append(parent_line)
        conf_parts.append(f'proxy -p{listen_port} -a')  # -a = allow all, -p = port
        conf_parts.append('')

        # Log proxy info for debugging
        auth_info = f" with auth" if user and password else " without auth"
        print(f"Configuring {protocol.upper()} proxy {host}:{port}{auth_info} on gateway port {listen_port}")
        
        valid_proxies.append(proxy_line)

    # Write the final config file
    os.makedirs(os.path.dirname(proxy3_conf_file), exist_ok=True)
    with open(proxy3_conf_file, 'w') as f:
        f.write('\n'.join(conf_parts))
    
    print(f"Successfully generated 3proxy.cfg for {len(valid_proxies)} proxies.")

if __name__ == '__main__':
    main()

