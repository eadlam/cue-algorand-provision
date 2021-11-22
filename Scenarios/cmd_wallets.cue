package algo

import (
    "tool/exec"
    "tool/cli"
)

let network_data_dir = "bin/networks/\(Network.name)"

command: wallets: {
    for k, v in Network.template.Nodes {

        "wallets_\(v.Name)": {
            exec.Run
            cmd: "goal wallet list -d \(network_data_dir)/\(v.Name)"
            stdout: string
        }

        // "accounts_\(v.Name)": {
        //     exec.Run
        //     cmd: "goal account list -d \(network_data_dir)/\(v.Name)"
        //     stdout: string
        // }

        "print_wallets_\(v.Name)": {
            cli.Print
            text: v.Name + " wallets:\n" + wallets["wallets_\(v.Name)"].stdout
        }

        // "print_accounts_\(v.Name)": {
        //     cli.Print
        //     text: v.Name + " accounts:\n" + wallets["accounts_\(v.Name)"].stdout
        //     $after: wallets["print_wallets_\(v.Name)"]
        // }

    }
}