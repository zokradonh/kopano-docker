#!/bin/sh

which konnectd

cat << 'EOF' >> /commander/konnectd
#!/bin/sh
echo konnectd $@
EOF

chmod +x /commander/konnectd
which konnectd


exit 0
