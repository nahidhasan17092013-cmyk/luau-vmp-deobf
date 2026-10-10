# Coin Rush

A round-based coin collecting game for Roblox. The arena is generated at runtime, so there is nothing to build by hand.

- 90 second rounds with a 10 second intermission.
- Normal coins are worth 1, golden coins are worth 5.
- Lava pools kill you instantly.
- Green jump pads launch you onto floating platforms where the golden coins are.
- Most coins at the end of the round wins. `Wins` are saved with DataStores.
- Everyone is shown in the built-in player list through `leaderstats`.

## Run it

Needs [Rojo](https://rojo.space) 7.x.

```
cd roblox-game
rojo build -o CoinRush.rbxlx   # then open CoinRush.rbxlx in Roblox Studio
# or: rojo serve, and connect from the Rojo Studio plugin
```

Press Play (or Play Here) in Studio. Enable *Game Settings > Security > Enable Studio Access to API Services* to test saving wins.

Without Rojo, create the scripts by hand: `Config` (ModuleScript) in ReplicatedStorage, `Main` (Script) in ServerScriptService, `HUD` (LocalScript) in StarterPlayerScripts, and paste in the matching files from `src/`.

Tweak `src/ReplicatedStorage/Config.luau` for round length, coin counts and jump pad strength.
