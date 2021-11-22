#!/usr/bin/env python3

from pyteal import *


def main():
    program = Return(Int(1))
    return compileTeal(program, Mode.Application, version=5)


if __name__ == "__main__":
    print(main())
