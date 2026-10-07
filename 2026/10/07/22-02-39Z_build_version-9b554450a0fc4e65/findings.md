[![Moraine Roblox Datamining](https://github.com/MoraineArchive/Moraine-asset/blob/main/roblox/banner_roblox.png?raw=true)](https://github.com/MoraineArchive/Moraine-asset/blob/main/roblox/banner_roblox.png)

# Findings

## Animated images

**Classification:** single-source

**First observed:** `2026-09-08T23:47:55.817Z`

- Evidence removed from API: `AnimatedImagePlaybackState.Canceled` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Evidence removed from API: `AnimatedImage.Function.GetBoundTracks` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Observed in API: `AnimatedImageService.Property.UserCreatedTracks` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Evidence removed from API: `AnimatedImagePlaybackState.Completed` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Observed in API: `AnimatedImageService` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Evidence removed from API: `AnimatedImagePlaybackState` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Evidence removed from API: `AnimatedImage.Function.Pause` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Evidence removed from API: `AnimatedImage.Property.PlaybackSpeed` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Evidence removed from API: `AnimatedImagePlaybackState.Paused` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Observed in API: `AnimatedImageService.Function.CreateTrack` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Evidence removed from API: `AnimatedImage.Function.Resume` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Observed in API: `AnimatedImageService.Function.DestroyTrack` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Evidence removed from API: `AnimatedImage` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Evidence removed from API: `AnimatedImagePlaybackState.Playing` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Evidence removed from API: `AnimatedImagePlaybackState.Begin` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Evidence removed from API: `AnimatedImage.Property.Content` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Observed in API: `AnimatedImageScaleType.Fit` (2026/09/08/23-47-55Z_build_version-93202a13414c4131)
- ... and 86 more evidence records


## Moments capture/post API

**Classification:** strongly-correlated

**First observed:** `2026-09-08T23:47:55.817Z`

- Observed in Distribution: `ExtraContent/LuaPackages/Packages/_Index/MomentsCreationFlow/Foundation.lua` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Observed in LiveSettings: `FFlagMomentsUseSmallOverflowMenu` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Observed in Source: `extracontent-luapackages/Packages/_Index/MomentsCommon/Foundation.lua` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Observed in Source: `extracontent-luapackages/Packages/_Index/MomentsCreationFlow/Foundation.lua` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Evidence removed from LiveSettings: `FFlagMomentsUseSmallOverflowMenu_Staged` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Observed in Source: `extracontent-luapackages/Packages/_Index/MomentsCreationFlow/Foundation.lua` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Observed in Distribution: `ExtraContent/LuaPackages/Packages/_Index/MomentsCommon/Foundation.lua` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Observed in Distribution: `ExtraContent/LuaPackages/Packages/_Index/MomentsCommon/lock.toml` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Observed in Distribution: `ExtraContent/LuaPackages/Packages/_Index/MomentsCreationFlow/lock.toml` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Observed in Source: `extracontent-luapackages/Packages/_Index/MomentsCommon/Foundation.lua` (2026/10/07/22-02-39Z_build_version-9b554450a0fc4e65)
- Observed in API: `MomentsService` (2026/09/08/23-47-55Z_build_version-93202a13414c4131)
- ... and 116 more evidence records

Observed staged-to-non-staged transition.
