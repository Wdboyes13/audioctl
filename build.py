#!/usr/bin/env python3
import argparse
import json
import os
import shutil
import stat
import subprocess

exe_path = ".build/debug/audioctl"


def get_tarname():
    out = subprocess.run(
        ["swift", "package", "dump-package"], capture_output=True, text=True
    )
    data = json.loads(out.stdout)
    name = data["name"]
    return name + ".tar.gz"


def swift_build() -> None:
    res = subprocess.run(["swift", "build"])
    exit(res.returncode)


def install(prefix: str) -> None:
    bindir = os.path.join(prefix, "bin")
    if not os.path.exists(bindir):
        os.makedirs(bindir)
    dest_path = os.path.join(bindir, os.path.basename(exe_path))
    shutil.copyfile(exe_path, dest_path)
    mode: int = (
        stat.S_IRUSR
        | stat.S_IWUSR
        | stat.S_IXUSR
        | stat.S_IRGRP
        | stat.S_IXGRP
        | stat.S_IROTH
        | stat.S_IXOTH
    )

    os.chmod(dest_path, mode)
    print(f"Installed to {dest_path}")
    exit(0)


def distribute() -> None:
    cwd = os.getcwd()
    tarname = get_tarname()
    subprocess.run(
        [
            "tar",
            "-czvf",
            f"{cwd}/{tarname}",
            "Sources/",
            "build.py",
            "Package.swift",
            "README.md",
        ],
        cwd=cwd,
    )
    print(f"Created distribution: {tarname}")


def main():
    parser = argparse.ArgumentParser(description="Build helper for audioctl")
    parser.add_argument(
        "action",
        choices=["install", "build", "dist"],
        help="Action to perform (install|build|dist)",
    )
    parser.add_argument(
        "-p",
        "--prefix",
        help="Prefix for installation",
        default="/usr/local",
    )

    args = parser.parse_args()

    if args.action == "build":
        swift_build()
    elif args.action == "install":
        install(args.prefix)
    elif args.action == "dist":
        distribute()


if __name__ == "__main__":
    main()
