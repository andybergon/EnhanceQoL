#!/usr/bin/env python3
import json
import os
import re
import sys
import urllib.error
import urllib.request


def release_type(tag):
    lowered = tag.lower()
    if "alpha" in lowered:
        return "alpha"
    if "beta" in lowered:
        return "beta"
    return "release"


def webhook_for(kind):
    if kind == "alpha":
        return os.environ.get("DISCORD_ALPHA_WEBHOOK") or os.environ.get("DISCORD_BETA_WEBHOOK")
    if kind == "beta":
        return os.environ.get("DISCORD_BETA_WEBHOOK")
    return os.environ.get("DISCORD_RELEASE_WEBHOOK")


def extract_notes(changelog, tag):
    heading = re.compile(r"^## \[(?P<tag>[^\]]+)\].*$")
    lines = changelog.splitlines()
    start = None
    end = None

    for index, line in enumerate(lines):
        match = heading.match(line)
        if not match:
            continue
        if match.group("tag") == tag:
            start = index + 1
            continue
        if start is not None:
            end = index
            break

    if start is None:
        return ""

    section = lines[start:end]
    while section and section[0].strip() == "":
        section.pop(0)
    while section and section[-1].strip() in ("", "---"):
        section.pop()
    return "\n".join(section).strip()


def chunks(text, size=3900):
    remaining = text.strip()
    while len(remaining) > size:
        split_at = remaining.rfind("\n", 0, size)
        if split_at < 1:
            split_at = size
        yield remaining[:split_at].strip()
        remaining = remaining[split_at:].strip()
    if remaining:
        yield remaining


def post(webhook, payload):
    data = json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(
        webhook,
        data=data,
        headers={
            "Content-Type": "application/json",
            "User-Agent": "EnhanceQoL-GitHub-Actions",
        },
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=20) as response:
        if response.status >= 300:
            raise RuntimeError(f"Discord returned HTTP {response.status}")


def main():
    tag = os.environ.get("TAG_NAME") or os.environ.get("GITHUB_REF_NAME")
    if not tag:
        print("No tag name found in GITHUB_REF_NAME/TAG_NAME.", file=sys.stderr)
        return 1

    kind = release_type(tag)
    webhook = webhook_for(kind)
    if not webhook:
        print(f"No Discord webhook configured for {kind}; skipping Discord patchnotes.")
        return 0

    changelog_path = os.environ.get("CHANGELOG_FILE", "CHANGELOG.md")
    with open(changelog_path, encoding="utf-8") as handle:
        changelog = handle.read()

    notes = extract_notes(changelog, tag)
    if not notes:
        print(f"No CHANGELOG.md section found for tag {tag}; skipping Discord patchnotes.")
        return 0

    repo = os.environ.get("GITHUB_REPOSITORY", "")
    release_url = f"https://github.com/{repo}/releases/tag/{tag}" if repo else None
    color = 0x57F287 if kind == "release" else 0xFEE75C
    title_kind = "Release" if kind == "release" else kind.capitalize()

    note_chunks = list(chunks(notes))
    embeds = []
    for index, part in enumerate(note_chunks[:10]):
        suffix = f" ({index + 1}/{len(note_chunks)})" if len(note_chunks) > 1 else ""
        embed = {
            "title": f"EnhanceQoL {tag} {title_kind}{suffix}",
            "description": part,
            "color": color,
        }
        if release_url:
            embed["url"] = release_url
        embeds.append(embed)

    payload = {
        "username": "EnhanceQoL Releases",
        "content": f"EnhanceQoL {tag} has been released.",
        "embeds": embeds,
    }

    try:
        post(webhook, payload)
    except urllib.error.HTTPError as error:
        print(f"Discord webhook failed with HTTP {error.code}: {error.read().decode('utf-8', 'replace')}", file=sys.stderr)
        return 1

    print(f"Posted {kind} patchnotes for {tag} to Discord.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
