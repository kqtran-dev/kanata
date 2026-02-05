#!/usr/bin/env python3

import socket
import json
import sys
import os
import tomllib
import logging
import argparse

loglevel = logging.CRITICAL
#loglevel = logging.DEBUG

logger = logging.getLogger(__name__)
logging.basicConfig(filename='/tmp/kanata-layer.log',
                    encoding='utf-8',
                    level=loglevel,
                    format='%(asctime)s %(levelname)s: %(message)s')

def different_change(old, new):
    newj = json.loads(new)
    if "ChangeLayer" in newj.keys() and newj["ChangeLayer"]["new"] == old["LayerChange"]["new"]:
        return False
    return True


def api_call(conf, msg=None):
    HOST = conf.get("host", "127.0.0.1")
    PORT = conf.get("port", 12321)
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.connect((HOST, PORT))
            servermsg = s.recv(1024)
            parsed_msg = json.loads(servermsg)
            if msg and different_change(parsed_msg, msg):
                s.sendall(msg.encode())
                servermsg = s.recv(1024)
                return json.loads(servermsg)
            return parsed_msg
    except ConnectionRefusedError:
        logger.error("Connection Refused")
        sys.exit("Connection Refused")

def create_all_layers_msg():
    msg = {"RequestLayerNames": {}}
    return json.dumps(msg)

def create_change_msg(layername):
    msg = {"ChangeLayer": { "new": layername }}
    return json.dumps(msg)

def read_config():
    global args
    try:
        with open(os.path.expanduser(args.config), "rb") as f:
            conf = tomllib.load(f)
            return conf
    except FileNotFoundError:
        logger.info("Config file not found. Using default config")
        return {}

def list_layers(args):
    logger.debug("List Layers")
    conf = read_config()
    ret = api_call(conf, create_all_layers_msg())
    for layer in ret["LayerNames"]["names"]:
        print(layer)

def change_layer(args):
    logger.debug("Change Layer")
    conf = read_config()
    if not args.layer:
        layer = conf.get("base-layer", "base-layer")
    else:
        layer = args.layer
    ret = api_call(conf, create_change_msg(layer))
    print(ret)

def current_layer(args):
    logger.debug("Current Layer")
    conf = read_config()
    ret = api_call(conf)
    print(ret["LayerChange"]["new"])


def follow(args):
    conf = read_config()
    HOST = conf.get("host", "127.0.0.1")
    PORT = conf.get("port", 12321)

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST, PORT))

        # initial state
        buf = s.recv(4096)
        if buf:
            msg = json.loads(buf)
            if "LayerChange" in msg:
                print(msg["LayerChange"]["new"], flush=True)

        # stream updates
        while True:
            buf = s.recv(4096)
            if not buf:
                break
            msg = json.loads(buf)
            if "LayerChange" in msg:
                print(msg["LayerChange"]["new"], flush=True)


parser = argparse.ArgumentParser(
                    prog='kanata-layer',
                    description='Manages kanata-layers',
                    add_help=True
                    )

parser.add_argument('-c', '--config', help="Use specific config-file.toml", default="~/.config/kanata-layer/kanata-layer.toml")
parser.set_defaults(func=current_layer)
subparsers = parser.add_subparsers(help='subcommand help')
parser_list = subparsers.add_parser('list', help='list help')
parser_list.set_defaults(func=list_layers)
parser_layer = subparsers.add_parser('change', help='change layer help')
parser_layer.add_argument('-l','--layer', help="layername to change")
parser_layer.set_defaults(func=change_layer)
parser.add_argument('--follow', action='store_true')
args = parser.parse_args()
if args.follow:
    follow(args)
else:
    args.func(args)

exit(0)
