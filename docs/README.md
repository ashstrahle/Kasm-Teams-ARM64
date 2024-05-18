# Kasm-Teams-ARM64
**Teams ARM64 Client** for Kasm (Ideal for Raspberry Pi)

Containerised Teams client, streamed to your browser

![](/docs/screenshot1.png)

![](/docs/screenshot2.png)


This repository creates a custom Kasm Teams ARM64 client image.

## Acknowledgements

This build uses [Ismael Martinez](https://github.com/IsmaelMartinez)'s ARM64 build of [Teams for Linux](https://github.com/IsmaelMartinez/teams-for-linux)

## Installation

- Run the following to create the required Docker image:

      docker build -t teams -f Dockerfile .

- Create the Kasm image as per below:

![](/docs/screenshot3.png)

- Be sure to configure **Persistent Profile Path** so that user details are saved.

Enjoy!
