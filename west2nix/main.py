#!/usr/bin/env python3
from concurrent import futures
import subprocess
import argparse
import os.path
import tomlkit
import yaml
import json


def project_path(project: dict) -> str:
    return project.get("path", project["name"])


def prefetch_project(project: dict):
    path = project_path(project)

    print(f"Fetching {project['url']} from path {path}")

    proc = subprocess.run([
        "nix-prefetch-git",
        "--quiet",
        "--fetch-submodules",
        "--url", os.path.abspath(path),  # Use project_path for faster cloning
        "--rev", project["revision"],
    ], check=True, stdout=subprocess.PIPE)

    project["nix"] = {
        "hash": json.loads(proc.stdout)["hash"],
    }


argparser = argparse.ArgumentParser(description="""
Creates a frozen west manifest augmented with Nix hashes
""")
argparser.add_argument("--max-workers", type=int, help="limit the number of concurrent nix-prefetch-git calls")


def main():
    args = argparser.parse_args()

    proc = subprocess.run(["west", "manifest", "--freeze"], check=True, stdout=subprocess.PIPE)
    manifest = yaml.load(proc.stdout, Loader=yaml.CLoader)

    with futures.ThreadPoolExecutor(max_workers=args.max_workers) as executor:
        for project in manifest["manifest"]["projects"]:
            executor.submit(prefetch_project, project)

    with open("west2nix.toml", "w") as outf:
        tomlkit.dump(manifest, outf)

    print("Wrote west2nix.toml")
