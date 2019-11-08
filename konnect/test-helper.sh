#!/bin/sh

# add a dummy for the konnectd binary
cat << 'EOF' >> /commander/konnectd
#!/bin/sh
echo konnectd $@
EOF

chmod +x /commander/konnectd

exit 0
