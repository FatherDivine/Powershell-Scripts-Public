# NC Keysight License Configurator

## Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Usage](#usage)
- [Contributing](../CONTRIBUTING.md)

## About <a name = "about"></a>

Purpose of this Function/Module is to update the environment variable on Keysight, as the server changed ports.

Idea is to have all software license (and config) changes in module form, so if a license needs changing one can just type "Set-<SoftwareName>License" to update the licensing of that software on a local PC or remotely (easy fog snap-in: ps1 script that just has "Set-<SoftwareName>License" or pull newest version from GitHub repo) But if modules are automatically being pushed/updated (possible worthwhile GroupPolicy), then there's no need. When we get university github, Fog can pull from there, using token (talk to Aman for more information on how that works)

Could also load them onto all pcs from a local one by typing:

Set-<SoftwareName>License -ComputerName $PCList (or single pc).

This will become a template for all software license updaters (or configuration changers) so we can easily deploy to the local PC (if parameter "-ComputerName" is not set ) or to a range of PCs using the parameter. If one puts localhost in the parameter the logic will allow for a PC to 

This will serve as a template for other times we must edit the configuration of software.


## Getting Started <a name = "getting_started"></a>

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See [deployment](#deployment) for notes on how to deploy the project on a live system.

### Prerequisites

What things you need to install the software and how to install them.

```
Give examples
```

### Installing

A step by step series of examples that tell you how to get a development env running.

Say what the step will be

```
Give the example
```

And repeat

```
until finished
```

End with an example of getting some data out of the system or using it for a little demo.

## Usage <a name = "usage"></a>

Add notes about how to use the system.
