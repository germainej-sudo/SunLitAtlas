# Web student access test

This adds the `Web Student Test` export preset. It does not publish a website, enable GitHub Pages, or change the Windows preset. This is an early device access test, not a finished classroom release.

## Make the browser build

1. In GitHub Desktop, fetch and pull `main`. Use `Show in Explorer` to identify the updated project folder. Open that folder's `project.godot`, not an older ZIP copy.
2. In Godot, open `Editor > Manage Export Templates` and install the templates matching the exact version of your Godot editor. Do not change engine versions just for this test.
3. Open `Project > Export` and select `Web Student Test`. Click `Export Project`, not `Export PCK/ZIP`. Create the `builds/web_student` folder if needed and export as `index.html`. Leave `Export With Debug` unchecked for the student build.
4. Keep every generated file together with its original name. The HTML page alone is not the game.

For a quick local browser check, the runnable Web preset enables Godot's browser preview button once the matching export templates are installed. A normal F5 run is still the native game, not the browser export.

To test the actual exported files, an optional local command from the project folder is:

```sh
python -m http.server 8060 --bind 127.0.0.1 --directory builds/web_student
```

Open `http://localhost:8060/`. Use `python3` or `py` in place of `python` if appropriate. This serves only the exported folder on your own machine; it does not create a student link. Do not double click `index.html` to test it through a file URL.

## Test on a student Chromebook

The exported folder still needs an approved HTTPS host before a student can open a link. Upload the contents of `builds/web_student`, not the source repository. GitHub Pages is one possible host, but publishing requires a separate setup and a visibility decision. Nothing in this commit deploys automatically. The `noindex` request is not access control.

Use one actual student account on a district Chromebook and the school network. Open the hosted game directly in a browser tab first, not embedded in Canvas. A successful teacher device test does not verify student access.

During a five minute test, check that the title loads, Liora moves and scrolls, E opens a character conversation, Journal and Map work, text fits, and sound plays after clicking inside the game. Save, close the tab, reopen the same address, and test Continue. Record the device model, browser version, approximate load time, and exact error if one appears. No student name is needed.

Ask district IT to review a blocked host or restricted WebGL; do not bypass school controls. Browser saves depend on local storage and district policies. They are not cloud saves, do not move automatically from Windows, and may be cleared when a student signs out or browser data is removed.

## Configuration and privacy

The existing Compatibility renderer is retained. The preset disables threads and GDExtensions, avoiding their special isolation header requirement. It uses adaptive canvas sizing and includes the authored JSON data. PWA caching is disabled for this early test to reduce stale build confusion.

The `student_test` feature prevents the optional AI service from loading an environment key or sending a Gemini request, even if a key is entered in settings. Authored dialogue remains available. The existing optional AI controls remain visible in this first access test; submitting a question returns a message that online AI is disabled. Do not enter credentials or personal information. The normal Windows/editor behavior is unchanged; custom feature tags apply to exports, not a normal F5 run.

No analytics or student tracking was added. This does not prevent a hosting provider from keeping ordinary access logs. Do not include student files, account tokens, or keys when publishing.

## Validation status

Static checks passed for preset syntax, the unchanged Windows configuration, required JSON inclusion, thread/extension/PWA settings, and placement of the AI request guard. No Godot executable was available in the editing environment, so the actual export, GDScript execution, browser runtime, and school network access have not been validated. This commit provides the configuration, not a verified playable URL.

Official references:

* https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
* https://docs.godotengine.org/en/stable/classes/class_editorexportplatformweb.html
* https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html
