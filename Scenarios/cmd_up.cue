package algo

import (
    "encoding/json"
    "tool/exec"
    "tool/cli"
    "tool/file"
)

// bin directory paths
let materialize_dir = "bin/materialized"
let networks_dir = "bin/networks"
let apps_dir = "bin/apps"

// Network / Node directory and file paths
let network_data_dir = "\(networks_dir)/\(Network.name)"
let genesis_json = "\(materialize_dir)/\(Network.name).json"

// Scenario directory paths
let scenario_instance_dir = "Scenarios/\(Network.name)/\(Scenario)/instance"

// Generated scenario instance files
let GenesisData = #"""
package algo

GenesisData: \#(command.up.read_genesis.contents)
GenesisAccounts: {
    for i in GenesisData.alloc {
        {"\(i.comment)": i}
    }
}
"""#

// Create network, wallets, accounts, apps, and write data to Scenarios/[network]/[scenario]/instance directory
command: up: {

    // Create bin and and scenario instance directories
    mkdirs: {
        exec.Run
        cmd: "mkdir -p \(materialize_dir) \(networks_dir) \(apps_dir) \( scenario_instance_dir)"
    }

    // Write out genesis.json needed by goal network create
    materialize: {
        file.Create
        filename: genesis_json
        contents: json.Marshal(Network.template)
        $after: mkdirs
    }

    // Create Network
    network_create: {
        exec.Run
        cmd: "goal network create -n \(Network.name) -t \(genesis_json) -r \(network_data_dir)"
        stdout: string
        $after: materialize
    }

    // print stdout for: goal network create
    print_network_create: {
        cli.Print
        text: network_create.stdout
    }

    // If any nodes have config.json specified, overwrite the default config.json for that node
    for node in Network.template.Nodes if node.config != _|_ {
        "config_network_\(node.Name)": {
            file.Create
            filename: "\(network_data_dir)/\(node.Name)/config.json"
            contents: json.Marshal(node.config)
            $after: network_create
        }
    }


    // Read in genesis.json so we can write it out as contents in a cue file 
    read_genesis: {
        file.Read
        filename: network_data_dir + "/genesis.json"
        contents: string
        $after: network_create
    }

    // write out the genesis.cue file
    write_cue_genesis: {
        file.Create
        filename:  scenario_instance_dir + "/genesis.cue"
        contents: GenesisData
        $after: read_genesis
    }

    // Start the network
    network_start: {
        exec.Run
        cmd: "goal network start -r \(network_data_dir)"
        stdout: string
        $after: network_create
    }

    for k, v in Network.template.Nodes {
        // start kmd on each node data directory
        "kmd_start_\(v.Name)": {
            exec.Run
            cmd: "goal kmd start -d \(network_data_dir)/\(v.Name)"
            stdout: string
            $after: network_start
        }
    }


    // Create Wallets
    for userName, user in Users {
        for walletName, wallet in user.wallets {
            "create_\(walletName)": {
                exec.Run
                cmd: "./algo -d \(network_data_dir)/\(wallet.node) wallet new \(userName) \(walletName)"
                stdout: string
                $after: up["kmd_start_\(wallet.node)"]
            }
            "save_\(walletName)": {
                file.Create
                filename: "\(scenario_instance_dir)/\(userName).\(walletName).cue"
                contents: "package algo\n\n" + up["create_\(walletName)"].stdout
                $after: up["create_\(walletName)"]
            }
        }
    }

    // Create Accounts
    for userName, user in Users {
        for walletName, wallet in user.wallets {
            for accountName, account in wallet.accounts {
                "create_\(walletName)_\(accountName)": {
                    exec.Run
                    cmd: "./algo -d \(network_data_dir)/\(wallet.node) account new -u \(userName) -w \(walletName) -p \(walletName)_password \(accountName)"
                    stdout: string
                    $after: up["create_\(walletName)"]
                }
                "save_\(walletName)_\(accountName)": {
                    file.Create
                    filename: "\(scenario_instance_dir)/\(userName).\(walletName).\(accountName).cue"
                    contents: "package algo\n\n" + up["create_\(walletName)_\(accountName)"].stdout
                    $after: up["create_\(walletName)"]
                }
            }
        }
    }

    // Create Apps
    for appName, accounts in Apps {
        // Create bin/apps/[appName] directory
        "mkdir_\(appName)": {
            exec.Run
            cmd: "mkdir -p bin/apps/\(appName)"
            stdout: string
        }

        // compile approval.py
        "create_\(appName)_approval": {
            exec.Run
            cmd: "python3 -m apps.\(appName).approval"
            stdout: string
            $after: up["mkdir_\(appName)"]
        }
        // write approval.teal
        "save_\(appName)_approval": {
            file.Create
            filename: "bin/apps/\(appName)/approval.teal"
            contents: up["create_\(appName)_approval"].stdout
            $after: up["create_\(appName)_approval"]
        }
        // compile clear_state.py
        "create_\(appName)_clear_state": {
            exec.Run
            cmd: "python3 -m apps.\(appName).clear_state"
            stdout: string
            $after: up["save_\(appName)_approval"]
        }
        // write clear_state.teal
        "save_\(appName)_clear_state": {
            file.Create
            filename: "bin/apps/\(appName)/clear_state.teal"
            contents: up["create_\(appName)_clear_state"].stdout
            $after: up["create_\(appName)_clear_state"]
        } 
    }
}
