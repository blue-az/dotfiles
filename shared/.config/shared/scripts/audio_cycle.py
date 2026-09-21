from dataclasses import replace

from audio_ports import Output, discover, parse_cards


def sink_name(output) -> str:
    card = output.card.replace("alsa_card.", "alsa_output.")
    # A duplex profile like `output:analog-stereo+input:analog-stereo` still
    # names its sink after the output half alone.
    profile = output.profile.removeprefix("output:").split("+", 1)[0]
    return f"{card}.{profile}"


def mark_default(outputs, default_sink):
    """Mark only the output behind the default sink as active.

    Every card holds an active profile, so with the PCH card's Line Out live
    alongside the HDMI card, the card-profile flag marks two outputs active and
    the cycle never leaves the first of them.
    """
    return [replace(o, active=sink_name(o) == default_sink) for o in outputs]


def next_output(outputs):
    if not outputs:
        return None
    for i, output in enumerate(outputs):
        if output.active:
            return outputs[(i + 1) % len(outputs)]
    return outputs[0]


def switch_commands(output) -> list:
    return [
        ["pactl", "set-card-profile", output.card, output.profile],
        ["pactl", "set-default-sink", sink_name(output)],
    ]


def cycle(dry_run=False):
    """Advance to the next live audio output. Returns its label, or None."""
    import subprocess

    text = subprocess.run(["pactl", "list", "cards"], capture_output=True, text=True).stdout
    default_sink = subprocess.run(
        ["pactl", "get-default-sink"], capture_output=True, text=True
    ).stdout.strip()
    target = next_output(mark_default(discover(parse_cards(text)), default_sink))
    if target is None:
        return None
    for cmd in switch_commands(target):
        if dry_run:
            print(" ".join(cmd))
        else:
            subprocess.run(cmd, capture_output=True, text=True)
    return target.label


if __name__ == "__main__":
    import sys

    label = cycle(dry_run="--dry-run" in sys.argv)
    print(label if label else "no live audio output")
