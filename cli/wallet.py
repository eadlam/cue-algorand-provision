#! /usr/bin/env python3

import os
import json
import click
from algosdk import kmd
from algosdk.wallet import Wallet
import pdb


# algo wallet
@click.group()
def wallet():
    pass


@wallet.command()
@click.argument("username")
@click.argument("name")
@click.pass_obj
def new(clients, username, name):
    password = "{}_password".format(name)
    wallet = Wallet(name, password, clients.kcl)
    data = {
        "Users": {
            username: {
                "wallets": {
                    name: {
                        "name": name,
                        "password": password,
                        "mnemonic": wallet.get_mnemonic(),
                    }
                }
            }
        }
    }
    print(json.dumps(data, indent=4))


if __name__ == "__main__":
    wallet()
