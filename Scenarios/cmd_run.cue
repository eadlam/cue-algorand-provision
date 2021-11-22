package algo

import (
    "tool/cli"
    "tool/exec"
)

let network_dir = "bin/networks/\(Network.name)"

GenesisAccounts: {...}

command: run: {
    // fund_accounts
    for userName, user in Users {
        for walletName, wallet in user.wallets {
            for accountName, account in wallet.accounts {
                "fund_\(walletName)_\(accountName)": {
                    exec.Run
                    cmd: "goal -d \(network_dir)/\(wallet.node) clerk send -w unencrypted-default-wallet -f \(GenesisAccounts.Faucet.addr) -t \(account.key) -a  \(account.stake * 100000000000000)"
                    stdout: string
                }

                "print_fund_\(walletName)_\(accountName)": {
                    cli.Print
                    text: "Funding: \(userName).\(walletName).\(accountName) (\(account.key))\n" + run["fund_\(walletName)_\(accountName)"].stdout
                }

            }
        }
    }

    // Create Apps
    for appName, accounts in Apps {
        for account in accounts {
            "deploy_\(appName)_\(account.wallet)_\(account.name)": {
                exec.Run
                cmd: "./algo -d \(network_dir)/\(account.node) app create -w \(account.wallet) -p \(account.wallet)_password \(account.key) ./bin/apps/\(appName)"
                stdout: string
                $after: run["fund_\(account.wallet)_\(account.name)"]
            }
            "print_deploy_\(appName)_\(account.wallet)_\(account.name)": {
                cli.Print
                text: "Creating app \"\(appName)\" for \(account.wallet).\(account.name):\n"  + run["deploy_\(appName)_\(account.wallet)_\(account.name)"].stdout
            }
        }
    } 
}