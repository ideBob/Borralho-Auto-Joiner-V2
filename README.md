# BORRALHO AUTO JOINER V2

Upgraded Roblox auto server-hop / auto-joiner for **Steal a Brainrot**.

## Features
- Refined dark UI with **Main**, **Logs** and **Min$** tabs
- Fully draggable main frame + floating RGB toggle button
- AutoJoin (server hop to free public servers)
- Logs tab with timestamped hop history
- **Min$ tab**: set minimum value filter (10M, 20M, 30M ... 1B)
- Priority high-value Brainrots list (Secrets / Gods / OGs)
- Scan button (placeholder — real rare scanning needs private API)
- Keybinds: `RightShift` = toggle UI | `J` = toggle AutoJoin

## Loadstring
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ideBob/Borralho-Auto-Joiner-V2/main/BorralhoAutoJoinerV2.lua"))()
```

## Min$ Tab
Select the minimum income/value you care about. This value is stored and will be sent to your private API when you connect one, so the scanner only returns servers that have Brainrots at or above your chosen threshold.

## Important Limitation
A pure client script **cannot** see which Brainrots are currently in other servers.  
The public Roblox servers API only returns player counts.  
Real "find servers that have high-value Brainrots" requires a private API + reporter network.

## Disclaimer
This is an executor/exploit script. Use at your own risk. Not affiliated with Roblox or the game developers.
