---
name: hostile-environment-testing
description: >
 Test installers, launchers, and scheduled scripts against messy,
 real-world conditions — not just a clean run on a convenient machine. Use
 before trusting any installer/setup script, any script run by cron or a
 scheduled task, or any code whose correctness depends on assumptions
 about the environment it runs in (which Python is found, what's on PATH,
 what folder it's run from, whether something else is already running).
 Trigger whenever a fix "works on my machine" or "worked in one test" and
 is about to be trusted for a wider rollout.
metadata:
  tier: machine
  plugin: skill-engineering
---

# Hostile Environment Testing

## Why this skill exists

On June 30 and July 1, 2026, four separate bugs shipped that all shared
one root cause: each was only ever tested against a clean, convenient
setup, and each one specifically broke under a messier, more realistic
condition that was never tried:

1. A Python-detection script was tested on a machine with one normal
 Python install. It broke on a real streamer's machine that also had
 Windows' fake Store-Python stub on PATH — a very common real-world
 condition, never tested.
2. A package-install step was tested on a machine with one Python. It
 silently installed to the wrong Python on a machine that had more than
 one — a condition several real streamers' machines actually have.
3. An installer was tested by running it from a fresh, empty folder. It
 crashed with "cannot perform a cyclic copy" the moment someone ran it
 from inside its own destination folder — an easy, realistic mistake.
4. Two monitoring scripts were tested by running them manually from a
 terminal (which starts in a home folder). They silently failed every
 time cron ran them, because cron starts in a different folder and
 nobody tested that specific path.

Every one of these passed a single, convenient, by-hand test. None of
them would have survived a deliberate test against a messier condition.
That's the gap this skill closes.

## The core rule

**A single clean test proves a happy path works. It proves nothing about
what happens on a real, messy machine.** Before trusting any installer,
launcher, or scheduled script — especially one going out to more than one
person, or running unattended — deliberately test it against conditions
less convenient than your own dev machine.

## Checklist — test against these conditions before trusting a script

For anything that installs software or detects an existing installation:
- Does the target machine have more than one version of the relevant
 runtime/tool installed? (More than one Python, more than one Node, etc.)
 Does the script correctly pick the right one, or could it silently pick
 the wrong one?
- Does the target machine have a decoy or fake version of the thing being
 detected? (Windows' built-in Python Store stub is a known, common trap —
 there may be others specific to other platforms/tools.)
- What happens if the script is run from an unexpected location —
 including from inside its own destination/output folder?
- What happens if the script is run a second time, over files it already
 created? Does it handle "already installed" gracefully, or does it
 assume a clean slate?
- What happens with no internet connection partway through, or a slow one?

For anything run by cron, a scheduled task, or any non-interactive
trigger:
- Does the script assume a working directory that only exists when a
 person runs it by hand? Test it by explicitly launching it the same way
 the scheduler will — not by running it yourself in a terminal, which
 starts somewhere different.
- Does it assume environment variables are set that only exist in an
 interactive login shell? Test with a stripped-down environment.
- Does it assume file paths are relative to somewhere that isn't
 guaranteed? Prefer paths anchored to the script's own location
 (`__file__`-relative, or equivalent) over relative/cwd-dependent paths.

For anything that silently fails (runs under a windowless/non-console
mode, like `pythonw` instead of `python`, or discards output):
- If it can fail silently, assume it will, eventually, for someone. Add a
 log file or another way to see what actually happened, even in the
 windowless/silent path — silence is only acceptable for the success
 case, never as the sole behavior for a failure case.

## How to actually run a hostile test

You often can't get a truly fresh second machine. Safe ways to simulate
one without needing hardware you don't have:
- Run the target script inside a subprocess with a deliberately restricted
 or altered PATH/environment (e.g. strip out the real tool's directory,
 leaving only a decoy) — scoped to that one process, not a system-wide
 change, so nothing real is disturbed.
- Run the script from a different working directory than usual, including
 from inside its own output folder if that's a plausible real mistake.
- Run the script twice in a row over its own prior output.
- If a lightweight, disposable clean environment is available (a sandbox,
 a container, a throwaway VM), prefer that over simulation when it's easy
 to set up — but don't let "no clean machine available" be a reason to
 skip hostile testing entirely; simulate instead.
- Never perform hostile testing against a machine that's currently doing
 real, live work (e.g. don't test against someone's live streaming setup)
 — isolate the test from anything currently in production use.

## Trigger this skill
- Before shipping any installer, launcher, or setup script change,
 especially one going to more than one person
- Before trusting any script that will run unattended (cron, scheduled
 tasks, systemd timers)
- Whenever a fix has been verified exactly once, on exactly one machine,
 and is about to be declared generally fixed
- As a standing check inside holistic-code-audit and comprehensive-audit
 whenever the diff touches an installer, launcher, or scheduled script
