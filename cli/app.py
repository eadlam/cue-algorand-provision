#! /usr/bin/env python3

import os
import json
import click
import base64

from algosdk.wallet import Wallet
from algosdk.future import transaction
import pdb

# Helpers
# source https://developer.algorand.org/docs/get-details/dapps/pyteal/
def compile_program(client, filepath):
    with open(filepath, "r") as f:
        compile_response = client.compile(f.read())
    return base64.b64decode(compile_response["result"])


def compile_app(client, approval_teal, clear_teal):
    return (compile_program(client, approval_teal), compile_program(client, clear_teal))


# helper function that waits for a given txid to be confirmed by the network
# Source: https://developer.algorand.org/docs/get-details/dapps/pyteal/
def wait_for_confirmation(client, transaction_id, timeout):
    """
    Wait until the transaction is confirmed or rejected, or until 'timeout'
    number of rounds have passed.
    Args:
        transaction_id (str): the transaction to wait for
        timeout (int): maximum number of rounds to wait
    Returns:
        dict: pending transaction information, or throws an error if the transaction
            is not confirmed or rejected in the next timeout rounds
    """
    start_round = client.status()["last-round"] + 1
    current_round = start_round

    while current_round < start_round + timeout:
        try:
            pending_txn = client.pending_transaction_info(transaction_id)
        except Exception:
            return
        if pending_txn.get("confirmed-round", 0) > 0:
            return pending_txn
        elif pending_txn["pool-error"]:
            raise Exception("pool error: {}".format(pending_txn["pool-error"]))
        client.status_after_block(current_round)
        current_round += 1
    raise Exception(
        "pending tx not found in timeout rounds, timeout value = : {}".format(timeout)
    )


# algo app
@click.group()
def app():
    pass


@app.command()
@click.option("-w", "--wallet", "wallet_name", help="Wallet Name")
@click.option("-p", "--pasword", "wallet_password", help="Wallet Password")
@click.argument("sender")
@click.argument("app_dir")
@click.pass_obj
def create(clients, wallet_name, wallet_password, sender, app_dir):

    approval_teal = os.path.join(app_dir, "approval.teal")
    assert os.path.exists(approval_teal), "Could not find {}".format(approval_teal)

    clear_teal = os.path.join(app_dir, "clear_state.teal")
    assert os.path.exists(clear_teal), "Could not find {}".format(clear_teal)

    # create a wallet object
    wallet = Wallet(wallet_name, wallet_password, clients.kcl)

    # compile app
    approval_program, clear_program = compile_app(
        clients.algod, approval_teal, clear_teal
    )

    # declare on_complete as NoOp
    on_complete = transaction.OnComplete.NoOpOC.real

    # get node suggested parameters
    params = clients.algod.suggested_params()

    # TODO: make these options
    # declare application state storage (immutable)
    local_ints = 0
    local_bytes = 0
    global_ints = 1
    global_bytes = 0
    global_schema = transaction.StateSchema(global_ints, global_bytes)
    local_schema = transaction.StateSchema(local_ints, local_bytes)

    # create unsigned transaction
    txn = transaction.ApplicationCreateTxn(
        sender,
        params,
        on_complete,
        approval_program,
        clear_program,
        global_schema,
        local_schema,
    )

    # sign transaction
    signed_txn = wallet.sign_transaction(txn)
    tx_id = signed_txn.transaction.get_txid()

    # send transaction
    clients.algod.send_transactions([signed_txn])

    # await confirmation
    wait_for_confirmation(clients.algod, tx_id, 5)

    # display results
    transaction_response = clients.algod.pending_transaction_info(tx_id)
    app_id = transaction_response["application-index"]
    print("Created new app-id:", app_id)

    return app_id


if __name__ == "__main__":
    app()
