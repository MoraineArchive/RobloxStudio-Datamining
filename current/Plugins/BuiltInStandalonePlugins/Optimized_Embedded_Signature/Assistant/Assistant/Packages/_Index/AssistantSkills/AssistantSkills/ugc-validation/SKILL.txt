---
name: ugc-validation
description: Check whether a UGC avatar item or bundle in the open place would pass Roblox upload validation using the asset_quality tool, then fix what can be fixed in Studio on a copy and explain how to fix the rest. Use when a creator's avatar item, accessory, layered clothing, shoes, head, body or animation fails validation (not moderation), gets rejected on upload, or they ask whether it is ready to upload.
---

# UGC Validation

Many creators are artists, not scripters. Explain problems and fixes in plain language, not check names.

| Command | Use when |
|---|---|
| `/validate-ugc` | Report whether the item passes and why. Change nothing. |
| `/fix-ugc` | Fix what you can on a copy, explain the rest. |

If `asset_quality` isn't in your tools, say validation isn't available in this Studio yet and stop. Don't try to reproduce validation yourself.

## Rules

- **Validate first, every time.** The tool's failures are exactly what must be fixed. Don't guess failures from the item, and don't add checks of your own.
- **Batch fixes.** Each validation can take minutes: make every fix you can, then validate once.
- **Pick the asset type from the item** (e.g. the accessory's type, or a bundle's parts). Ask if it isn't clear. Never switch types to get past checks.
- **Work on a copy.** Never edit the original. Put a clone in a Folder named `<Name>_fixed` next to the original, and keep the clone's name unless validation says it's wrong: validation checks it. Validate and fix the clone (e.g. `Workspace.Hat_fixed.Hat`), never the Folder. Keep a change log (instance, property, old value, new value) so every change can be explained and undone.
- **Never upload or publish anything** (meshes, images, animations, packages, places).
- **If a validation returns an `error`, or a failing result lists no failures, it didn't finish.** Fix it if it's about the item's layout or asset type, retry once if it looks transient, otherwise tell the creator and stop.
- **Keep the creator's intent.** Passing validation by changing what the item is counts as failure. Never delete or hide visible parts, textures or `SurfaceAppearance`s, clear a texture or map, or point a mesh, cage, texture or animation at a different asset on your own. Don't make changes just to clear warnings; they don't block upload.

## What you can and can't fix

**Can fix:** property and instance edits through `execute_luau`. That covers values, names, CFrames, attachments, schema values, reparenting, and removing things that don't render.

**Can't fix:** anything that needs new content. Explain why, and how the creator fixes it in their modelling, painting or animation tool.
- **Mesh geometry, UVs, skinning, cages, FACS.** Scripts can't write `MeshId`. `EditableMesh` and `EditableImage` edits stay in memory: they can't be saved or validated.
- **Texture pixels and animation keyframes.**
- **Studio-generated data** such as texture packs and HSR data.

**Visual changes need approval.** Decide from the kind of change whether it could change how the item looks on an avatar. That includes appearance properties, textures and meshes, size or position of visible parts, attachments, body scales, and adding or removing anything that renders. Describe each such change and get approval before applying it, unless the creator already approved it. Changes that can't be seen need no approval, but still go in the change log.

## Studio gotchas

- Leave parts unanchored: validation requires `Anchored = false`.
- `CollisionFidelity` set on a part in the place lands a moment later. Wait (e.g. `task.wait(0.1)`) before reading it back.

## Fix loop (`/fix-ugc`)

1. If a `<Name>_fixed` copy already exists, tell the creator and ask whether to keep working on it or start fresh (replacing it). If they keep it, validate the copy and skip to step 3.
2. Validate the original. If it passes, say so and stop. Otherwise make the copy.
3. Sort every failure into **safe fix**, **needs approval**, or **can't fix in Studio**. Use warnings as clues to the failures.
4. Ask once per round for all needs-approval changes. If the creator asked to go step by step, do one fix per round.
5. Apply the fixes, then re-validate the copy. New failures are normal; repeat from step 3.
6. Stop when the copy passes, when only unfixable failures remain, or when a round fixes nothing new.
7. Report:
   - the result;
   - where the copy is;
   - what you fixed;
   - what needs approval;
   - what can't be fixed in Studio and how to fix it;
   - the change log.
