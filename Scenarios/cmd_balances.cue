package algo

import (
    "tool/exec"
    "tool/cli"
)

let network_dir = "bin/networks/\(Network.name)"

command: balances: {

    for userName, user in Users {
        for walletName, wallet in user.wallets {
            "balances_\(walletName)": {
                exec.Run
                cmd: "./algo -d \(network_dir)/\(wallet.node) account balances -w \(walletName) -p \(walletName)_password"
                stdout: string
            }

            "print_balances_\(walletName)": {
                cli.Print
                text:  balances["balances_\(walletName)"].stdout
            }
        }
    }

    for k, v in Network.template.Nodes {
        "balances_\(v.Name)": {
            exec.Run
            cmd: "./algo -d \(network_dir)/\(v.Name) account balances -w unencrypted-default-wallet"
            stdout: string
        }

        "print_balances_\(v.Name)": {
            cli.Print
            text:  balances["balances_\(v.Name)"].stdout
        }
    }
    
}