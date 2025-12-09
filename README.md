# RD NOTIFY MESSAGE
> [!NOTE]
> Mod Version: 1.0.1

### Notification System for SM64 Coop DX

Category: Utility

Requires sm64coopdx v1.4 or above

## What's this mod?

Create custom visual notifications on screen to communicate with your friends during multiplayer. Perfect for announcing events, giving instructions, or just leaving funny messages.

## Commands (host only)

**Permanent Alerts:**
- `/rdt [message]` - Alert stays on screen until you remove it
- `/rdt` - Remove the current permanent alert

**Timed Alerts:**
- `/rdt5 [message]` - Shows for 5 seconds
- `/rdt10 [message]` - Shows for 10 seconds
- `/rdt15 [message]` - Shows for 15 seconds
- `/rdt20 [message]` - Shows for 20 seconds
- `/rdt30 [message]` - Shows for 30 seconds

## Customization Commands

- `/rdc [color]` - Change alert color
- `/rdn` - Toggle movement animation ON/OFF
- `/rdb` - Toggle glow effect ON/OFF (only works when movement is ON)

## Available Colors

**Basic Colors:**
black, white, red, blue, green, yellow, orange, purple, pink, cyan, magenta, lime, brown, gray, darkblue, darkgreen, darkred, gold, silver, maroon, navy, teal

**Themed Colors:**
mario_red, luigi_green, toad_blue, wario_yellow, wario_purple

**Special:**
rainbow (animated with glow effect)

## 🚨 Important: Movement vs Glow

**Movement ON + Glow ON:** Text moves with pulsing glow
**Movement ON + Glow OFF:** Text moves with solid color
**Movement OFF:** Text stays still, glow does nothing

## Quick Examples

Permanent red alert:
```
/rdt Welcome to the server
/rdc red
```

10 second rainbow alert:
```
/rdt10 Event starting in 10 min!
/rdc rainbow
```

Turn off glow but keep movement:
```
/rdn
/rdb
```

Turn off all effects:
```
/rdn
```

## Notes

- Long messages auto-wrap so they fit
- Timed alerts fade out smoothly
- Everyone sees the same alerts at the same time
- **HOST ONLY** - Only server host can use these commands

You're all set! thanks to Djoslin0 for Lib source
https://youtu.be/fGHupYHuAd8