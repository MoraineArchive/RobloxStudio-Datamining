---
name: rbx-generate-animation
description: How to use the generate_animation tool (Assistant /generate_animation) to create a character animation from a text description, or upscale an existing R6 animation to R15. Read before calling generate_animation, and use whenever the user asks to animate, make an animation, emote, dance, idle, walk/run cycle, or motion for a character or rig, or to upscale, convert, or rebuild an R6 animation to R15.
---

# Generating Animations with generate_animation

`generate_animation` sends a text description to the AutoAnim motion service, where an LLM planner turns it into motion. Studio then imports the result as a `KeyframeSequence`.

`generate_animation` has two modes: create a new animation from a text description, or upscale an existing R6 animation. New animations are R15+, and upscaled animations are converted from R6 to R15. Call `generate_animation` one at a time per Studio instance, and wait for one generation to finish before starting the next.

## 1. Preflight: choose a rig (optional)

- **External MCP clients:** skip this step and don't pass `instance_path`. The result isn't played on a rig, so the tool doesn't need one.
- **Studio Assistant:** follow this step. The result is previewed on the rig in the result card.

`instance_path` is optional. A rig is a `Model` with a `Humanoid` or an `AnimationController`.

- **If you pass it,** the tool animates that rig. It must be the full path to a rig `Model`, or the call fails.
- **If you omit it,** the tool animates the selected rig if there is one. Otherwise the tool inserts a default R15 rig to play the animation on.

Decide whether to pass it:

- **The user names a rig:** pass its full path as `instance_path`.
- **The user doesn't name a rig:** ask which rig to animate. If they don't choose, tell them the tool falls back as described in "If you omit it" above.
- **The user says to go ahead without choosing:** omit `instance_path`.

## 2. Write the prompt

If you're upscaling, skip this step and go to "Upscale an R6 animation" in step 3. Upscaling doesn't use a prompt.

The planner reads `textPrompt` as a description of **one character's body motion**. It does best when the prompt says:

- **The actions, in order:** "walks forward, stops, then waves with the right hand".
- **Counts:** "jumps three times", "two punches with the left fist".
- **Where the body goes:** in place, or travelling in a direction; turns and their size ("turns around to face back"); whether it ends where it started. Say this explicitly. The planner validates spatial intent, and a vague prompt often drifts.
- **Which limb:** "right arm", "both hands", "left leg".
- **Style or mood:** "tired", "excited", "sneaky", "heavy", "like a zombie". Style words are applied as a style pass, not as new actions.

Keep the user's intent. If the request is vague, fill in plausible details from the list above. Don't change or drop anything the user asked for.

Avoid, or tell the user up front that the result may not match:

- **Objects and scene geometry.** The model has no knowledge of the place. "Picks up the sword from the table" or "sits on that chair" can only be approximated as a mimed action at an assumed height.
- **More than one character**, or interaction with another character.
- **Fingers and facial expressions.** Body and arm motion are the reliable parts.
- **Camera directions** ("close-up", "from the side"). They have no effect.

| User says | Better `textPrompt` |
| --- | --- |
| "make him dance" | "a person does an energetic dance in place, bouncing and swinging both arms" |
| "a wave" | "a person stands in place and waves with the right hand, then lowers it" |
| "tired walk loop" | "a person walks forward slowly in a tired way, shoulders slumped, steady pace" |
| "jump attack" | "a person runs forward two steps, jumps, and swings both arms down hard while landing" |

## 3. Call the tool

The arguments you pass decide the mode: `textPrompt` creates a new animation, and `inputAssetId` upscales an existing one.

### Create a new animation

Pass the prompt from step 2. Pass `duration` only if the user asks for a specific length; otherwise omit it and the backend automatically picks the best length for the action.

```
generate_animation({
  textPrompt: "<prompt from step 2>",
  duration: <seconds>,              // only if the user asked for a length
  instance_path: "<rig from step 1>", // optional; see step 1
})
```

### Upscale an R6 animation

Pass the animation's asset id instead of a prompt. A bare number or `rbxassetid://<id>` both work. The source must be an R6 animation; anything else fails. `textPrompt` and `duration` are not used for upscaling.

```
generate_animation({
  inputAssetId: "<animation asset id>",
  instance_path: "<rig from step 1>", // optional; see step 1
})
```

Tell the user it has started and that a generation can take a few minutes.

## 4. After the tool returns

### Check the result

The tool saves each generation as a new `KeyframeSequence` under `ServerStorage.RBX_ASSISTANT_ANIMGEN`, and never overwrites an earlier one. The result tells you which one it is.

**External MCP clients** get these fields in the result:

```
{
  "status": "Animation generated successfully" or "Animation generation failed",
  "clipPath": "ServerStorage.RBX_ASSISTANT_ANIMGEN.<name>",
  "tag": "<CollectionService tag on the KeyframeSequence>",
  "publishedAssetId": "rbxassetid://<id>",
  "publishError": "<only present if publishing failed>",
  "failureReason": "<only present if the generation failed>",
  "message": "<readable error, only present if the generation failed>"
}
```

**Studio Assistant** gets these fields:

```
{
  "generationName": "<name of the KeyframeSequence>",
  "tag": "<CollectionService tag on the KeyframeSequence>",
  "duration": <length in seconds>,
  "failureReason": "<only present if the generation failed>"
}
```

If the result has a `failureReason`, the generation failed. See step 5.

If you passed a `duration` and the length is noticeably different, tell the user.

### Publishing behavior

- **External MCP clients:** each generation is also published as a new Animation asset in the user's or group's inventory. Check `publishedAssetId` in the result. Every regeneration creates another asset, so confirm changes with the user before regenerating repeatedly.
- **Studio Assistant:** nothing is published automatically. The user publishes from the Animation Clip Editor, or with the publish button on the result card.

### Follow-up changes

Users often follow up with "make it slower", "make it more tired", "add a jump at the end", or "use the left hand instead".

- **Only faster or slower:** offer local retiming. Scaling every `Keyframe.Time` in a copy of the existing `KeyframeSequence` is exact and needs no generation.
- **Any other change:** `generate_animation` doesn't edit existing animations. Start a new generation with a complete prompt that merges the original description and the change, and tell the user it will be a new motion, not an edit of the previous one.

## 5. Troubleshooting

| Symptom | What to do |
| --- | --- |
| Upscale fails to load the input clip | Check that `inputAssetId` is an R6 animation asset the user can access. |
| A generation runs for several minutes with no result | The cloud job is still running or is stuck. Check the Output for errors with `get_console_output`, tell the user what you found, and decide whether to retry. Don't start a second generation in parallel. |
| The job failed | Check the Output for errors with `get_console_output`, then retry once with a clearer prompt (step 2). If it fails again, report the error text to the user instead of looping. |

## 6. Report

Tell the user:

- the `KeyframeSequence` path;
- the prompt you sent, if you rewrote theirs;
- the length in seconds;
- that they can open it in the **Animation Clip Editor** to preview and adjust it;
- anything from step 2 that the result may not match, such as objects or a second character.

Also tell them:

- **External MCP clients:** the published asset id from `publishedAssetId`, or the `publishError` if publishing failed.
- **Studio Assistant:** that they can preview it in the result card, and publish it themselves (see "Publishing behavior" in step 4).
