package algo

import (
    "tool/exec"
    "tool/cli"
)

let network_dir = "bin/networks/\(Network.name)"

command: accounts: {

    for userName, user in Users {
        for walletName, wallet in user.wallets {
            "accounts_\(walletName)": {
                exec.Run
                cmd: "./algo -d \(network_dir)/\(wallet.node) account list -w \(walletName) -p \(walletName)_password"
                stdout: string
            }

            "print_accounts_\(walletName)": {
                cli.Print
                text:  accounts["accounts_\(walletName)"].stdout
            }
        }
    }

    for k, v in Network.template.Nodes {
        "accounts_\(v.Name)": {
            exec.Run
            cmd: "./algo -d \(network_dir)/\(v.Name) account list -w unencrypted-default-wallet"
            stdout: string
        }

        "print_accounts_\(v.Name)": {
            cli.Print
            text:  accounts["accounts_\(v.Name)"].stdout
        }
    }
    
}