#! /usr/bin/env python3

import os
import json
import click
from algosdk import kmd
from algosdk.wallet import Wallet
import pdb


# algo wallet
@click.group()
def account():
    pass


@account.command()
@click.option("-u", "--username", "user_name", help="User Name")
@click.option("-w", "--wallet", "wallet_name", help="Wallet Name")
@click.option("-p", "--pasword", "wallet_password", help="Wallet Password")
@click.argument("account_name")
@click.pass_obj
def new(clients, user_name, wallet_name, wallet_password, account_name):
    wallet = Wallet(wallet_name, wallet_password, clients.kcl)
    account = wallet.generate_key()
    data = {
        "Users": {
            user_name: {
                "wallets": {
                    wallet_name: {
                        "accounts": {
                            account_name: {
                                "wallet": wallet_name,
                                "name": account_name,
                                "key": account,
                            }
                        }
                    }
                }
            }
        }
    }
    print(json.dumps(data, indent=4))


@account.command()
@click.option("-w", "--wallet", "wallet_name", help="Wallet Name")
@click.option("-p", "--pasword", "wallet_password", help="Wallet Password")
@click.pass_obj
def balances(clients, wallet_name, wallet_password):
    wallet = Wallet(wallet_name, wallet_password, clients.kcl)
    output = "({}) {}:\n".format(clients.node, wallet_name)
    for i in wallet.list_keys():
        output += "  {}: {}\n".format(i, clients.algod.account_info(i).get("amount"))
    print(output)


@account.command()
@click.option("-w", "--wallet", "wallet_name", help="Wallet Name")
@click.option(
    "-p", "--pasword", "wallet_password", default=None, help="Wallet Password"
)
@click.pass_obj
def list(clients, wallet_name, wallet_password):
    wallet = Wallet(wallet_name, wallet_password, clients.kcl)
    output = wallet_name + ":\n"
    for i in wallet.list_keys():
        output += "  {}: {}\n".format(
            i, json.dumps(clients.algod.account_info(i), indent=4)
        )
    print(output)


@account.command()
@click.option("-w", "--wallet", "wallet_name", help="Wallet Name")
@click.option("-p", "--pasword", "wallet_password", help="Wallet Password")
@click.argument("address")
@click.pass_obj
def balance(clients, wallet_name, wallet_password, address):
    wallet = Wallet(wallet_name, wallet_password, clients.kcl)
    print(clients.algod.account_info(address).get("amount"))


if __name__ == "__main__":
    account()
