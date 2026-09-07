# Verification record

Target and tested runtime: Godot 4.7.2.stable.official.ed1daf0bf, Standard edition.
Host: macOS, Apple M1; Compatibility renderer (OpenGL over Metal).

## Automated checks

- Fresh source-project import: checked with the target Godot version.
- Integration suite: runs a reachable full-arc playthrough using the actual interaction and puzzle state functions. Checks missing prerequisites, wrong mechanism settings, all 20 sectors, all 22 sources, all six paper milestones, exact paired-door placement, recovery without lost knowledge, menu input suspension, offline AI fallback, atomic save roundtrip, malformed-save rejection, prior-snapshot recovery, and saving after recovery.
- Python content audit: checks that dependencies can reach the ending and all optional locations, every mechanism answer is valid, every door has a return, and a six-pixel player footprint can approach every object and door through collision geometry.
- Resource-pack export: checks runtime JSON and dynamically loaded assets are packaged; standalone pack smoke test uses the same Godot runtime.
- ZIP integrity and clean extraction: checked independently of the authoring project's import cache.

See the adjacent final test results for counts and packaging evidence.

## Rendered review

Eight real Godot viewport captures were produced: title, Brightwater exploration, dialogue, Sunleaf, a mechanism panel, the discovered-world map, coast, and ending. The title, exploration, mechanism, map, coast, and worksheet page were visually inspected for readable layout. These are QA captures; some screens use staged state rather than chronological gameplay. The printable worksheet has six pages.

## Gemini

The supplied auth key successfully reached Google's official generateContent endpoint. The initial 500-token request stopped at its limit; a second 1500-token request completed and produced the reviewed line in `data/gemini_mira.json`. That line is included in Mira's authored dialogue. Only the dialogue result and model name are packaged. The key and raw API response are excluded.

## Limits of the evidence

These checks do not prove the game is flawless, satisfy the unimplemented production GDD scope, measure campaign duration, validate every model response, or replace human playtesting. Windows executable export and physical controller hardware were not tested. Runtime resource packing and editor execution were tested; the Windows preset is supplied for the user's subsequent export.

## Final result

174 integration checks passed with zero failures. The geometry audit, fresh ZIP import, resource-pack export, and packed startup passed. Final engine logs contained no warnings or errors. Title-screen control changes were explicitly checked not to overwrite a journey.
