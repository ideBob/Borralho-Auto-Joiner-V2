# BORRALHO AUTO JOINER V2

Upgraded Roblox auto server-hop / auto-joiner for **Steal a Brainrot**.

## Features
- Refined dark UI with **Main** and **Logs** tabs
- Fully draggable main frame + floating RGB toggle button
- AutoJoin (server hop to free public servers)
- Logs tab with timestamped hop history
- Priority high-value Brainrots list (Secrets / Gods / OGs)
- Scan button (placeholder — real rare scanning needs private API)
- Keybinds: `RightShift` = toggle UI | `J` = toggle AutoJoin

## Loadstring
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ideBob/Borralho-Auto-Joiner-V2/main/BorralhoAutoJoinerV2.lua"))()
```

## Important Limitation
A pure client script **cannot** see which Brainrots are currently in other servers.  
The public Roblox servers API only returns player counts.  
Real "find servers that have Strawberry Elephant / specific Secrets" requires a private API + reporter network (like Lumora).

## Private API Sketch (High Level)
See the discussion in the repo issues / conversation for architecture ideas:
- Backend (Node/Python/Go) that stores JobId → list of rare Brainrots + timestamp
- Discord bot or in-game reporter that POSTs when a rare is spotted
- Client script polls `/rares` endpoint and teleports to matching JobIds
- Short TTL on entries (Brainrots move fast)

## Disclaimer
This is an executor/exploit script. Use at your own risk. Not affiliated with Roblox or the game developers.
