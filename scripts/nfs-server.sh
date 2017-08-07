#!/bin/bash
sudo mkdir /exports

kubectl label nodes `hostname` nfs-server=true

