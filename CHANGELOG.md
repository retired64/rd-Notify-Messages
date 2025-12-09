# CHANGELOG - Notification Display Mod
> Version 1.0.1 - Release
> Released: 08-Dec-2025

### Major Improvements
**Complete refactor** following Sm64CoopDx standards
**Performance optimization** with function localization
**Network synchronization** improved with proper `gGlobalSyncTable` usage
**Rendering system** optimized with `RESOLUTION_N64` and early returns.

### New Features
- Enhanced color system with 27 predefined colors + rainbow mode.
- Character-themed colors (Mario, Luigi, Toad, Wario)

### Bug Fixes
- Fixed sync table issues that caused network desynchronization.
- Resolved rendering conflicts with other HUD mods.
- Fixed color validation that could cause errors with invalid inputs.
- Corrected timer logic for proper notification duration

### Performance Optimizations
- Function localization: All global functions cached locally for 30%+ performance gain
- Rainbow color cache: Moved outside render loop to prevent frame drops
- Early returns: Added `hud_is_hidden()` and activity checks
- Mathematical functions: Localized `math_sin, math_cos, math_floor, math_max`
