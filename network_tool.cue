package algo

import (
    "encoding/json"
    "tool/exec"
    "tool/cli"
    "tool/file"
)

Network: {...}
let materialize_dir = "bin/materialized/\(Network.name)"
let genesis_json = "\(materialize_dir)/genesis.json"
let network_dir = Network.directory

command: launch: {
    mkdir: {
        exec.Run
        cmd: ["mkdir", "-p", "bin/materialized/\(Network.name)"]
    }
    materialize: {
        file.Create
        filename: genesis_json
        contents: json.Marshal(Network.template)
        $after: mkdir
    }
    network_create: {
        exec.Run
        cmd: ["goal", "network", "create", "-n", Network.name, "-t", genesis_json, "-r", network_dir]
        stdout: string
        $after: materialize
    }
    network_start: {
        exec.Run
        cmd: ["goal", "network", "start", "-r", network_dir]
        stdout: string
        $after: network_create
    }
    print: {
        cli.Print
        text: network_create.stdout
    }
}

command: status: {
    status: {
        exec.Run
        cmd: ["goal", "accounts", "status", "-r", network_dir]
        stdout: string
    }
    print: {
        cli.Print
        text: status.stdout
    }
}

command: accounts: {
    for k, v in Network.template.Nodes {

        "accounts_\(v.Name)": {
            exec.Run
            cmd: ["goal", "account", "list", "-d", "\(network_dir)/\(v.Name)"]
            stdout: string
        }

        "print_\(v.Name)": {
            cli.Print
            text: v.Name + " accounts:\n" + accounts["accounts_\(v.Name)"].stdout
        }

    }
}


command: delete: {
    network_delete: {
        exec.Run
        cmd: ["goal", "network", "delete", "-r", network_dir]
        stdout: string
    }
}