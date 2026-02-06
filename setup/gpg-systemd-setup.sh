#! /usr/bin/bash
# Scrip to produce the custom user socket files needed to not have ~/.gnugp

if [ -z "$GNUPGHOME" ]; then
  echo "\$GNUPGHOME is not set. Please set it to $HOME/.local/share/gnupg"
  exit 1
fi

echo "Setting up GPG systemd user socket files..."
echo "GNUPGHOME: $GNUPGHOME"

socketdir=$(gpgconf --list-dirs socketdir | sed s/'\/run\/user\/.*\/gnupg'/'%t\/gnupg'/)
echo "Socket directory: $socketdir"
mkdir -p $HOME/.config/systemd/user/gpg-agent.service.d

mv $HOME/.config/systemd/user/gpg-agent.service.d/override.conf $HOME/.config/systemd/user/gpg-agent.service.d/override.conf.bak 2>/dev/null
cat << EOF > $HOME/.config/systemd/user/gpg-agent.service.d/override.conf
[Service]
Environment="GNUPGHOME=%h/.local/share/gnupg"
EOF

mv $HOME/.config/systemd/user/gpg-agent.socket $HOME/.config/systemd/user/gpg-agent.socket.bak 2>/dev/null
cat << EOF > $HOME/.config/systemd/user/gpg-agent.socket
[Unit]
Description=GnuPG cryptographic agent and passphrase cache
Documentation=man:gpg-agent(1)

[Socket]
ListenStream=$socketdir/S.gpg-agent
FileDescriptorName=std
SocketMode=0600
DirectoryMode=0700
EOF

mv $HOME/.config/systemd/user/gpg-agent-ssh.socket $HOME/.config/systemd/user/gpg-agent-ssh.socket.bak 2>/dev/null
cat << EOF > $HOME/.config/systemd/user/gpg-agent-ssh.socket
[Unit]
Description=GnuPG cryptographic agent (ssh-agent emulation)
Documentation=man:gpg-agent(1) man:ssh-add(1) man:ssh-agent(1) man:ssh(1)

[Socket]
ListenStream=$socketdir/S.gpg-agent.ssh
FileDescriptorName=ssh
Service=gpg-agent.service
SocketMode=0600
DirectoryMode=0700
EOF

mv $HOME/.config/systemd/user/gpg-agent-extra.socket $HOME/.config/systemd/user/gpg-agent-extra.socket.bak 2>/dev/null
cat << EOF > $HOME/.config/systemd/user/gpg-agent-extra.socket
[Unit]
Description=GnuPG cryptographic agent and passphrase cache (restricted)
Documentation=man:gpg-agent(1)

[Socket]
ListenStream=$socketdir/S.gpg-agent.browser
FileDescriptorName=extra
Service=gpg-agent.service
SocketMode=0600
DirectoryMode=0700
EOF

mv $HOME/.config/systemd/user/gpg-agent-browser.socket $HOME/.config/systemd/user/gpg-agent-browser.socket.bak 2>/dev/null
cat << EOF > $HOME/.config/systemd/user/gpg-agent-browser.socket
[Unit]
Description=GnuPG cryptographic agent and passphrase cache (access for web browsers)
Documentation=man:gpg-agent(1)

[Socket]
ListenStream=$socketdir/S.gpg-agent.browser
FileDescriptorName=browser
Service=gpg-agent.service
SocketMode=0600
DirectoryMode=0700
EOF

mv $HOME/.config/systemd/user/dirmngr.socket $HOME/.config/systemd/user/dirmngr.socket.bak 2>/dev/null
cat << EOF > $HOME/.config/systemd/user/dirmngr.socket
[Unit]
Description=GnuPG network certificate management daemon
Documentation=man:dirmngr(8)

[Socket]
ListenStream=$socketdir/S.dirmngr
SocketMode=0600
DirectoryMode=0700
EOF

mv $HOME/.config/systemd/user/keyboxd.socket $HOME/.config/systemd/user/keyboxd.socket.bak 2>/dev/null
cat << EOF > $HOME/.config/systemd/user/keyboxd.socket
[Unit]
Description=GnuPG public key management service
Documentation=man:keyboxd(8)

[Socket]
ListenStream=$socketdir/S.keyboxd
FileDescriptorName=std
SocketMode=0600
DirectoryMode=0700
EOF

echo "Reloading systemd user daemon..."
systemctl --user daemon-reload