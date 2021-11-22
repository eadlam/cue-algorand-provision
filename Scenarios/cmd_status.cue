package algo

import (
    "tool/exec"
    "tool/cli"
)

let network_data_dir = "bin/networks/\(Network.name)"

command: status: {
    status: {
        exec.Run
        cmd: "goal network status -r \(network_data_dir)"
        stdout: string
    }
    print: {
        cli.Print
        text: status.stdout
    }
}
