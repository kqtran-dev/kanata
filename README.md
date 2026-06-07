# kanata
`sudo mkdir /etc/kanata`
`sudo cp kanata.kbd /etc/kanata/kanata.kbd`
`sudo install -m 644 kanata.service /lib/systemd/system/kanata.service`

`sudo systemctl daemon-reload`
`sudo systemctl start kanata`
`sudo systemctl enable kanata`

macos-dev-names-include
Use kanata -l or kanata --list to list the available keyboards.
