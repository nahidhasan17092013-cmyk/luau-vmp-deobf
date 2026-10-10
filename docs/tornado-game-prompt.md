# Tornado Game: Context Prompt

> Paste everything below the line into your AI tool or engine of choice.
> Items marked **[ASSUMPTION]** are my guesses, so change them to match your idea.

---

## 1. Role and goal

You are a senior game designer and gameplay engineer. Build a **tornado survival game**: the player lives through an escalating series of tornado outbreaks by preparing, scavenging, sheltering and escaping. The game should feel tense, readable and replayable, with a clear loop of *prepare -> survive -> recover -> upgrade*.

**[ASSUMPTION]** Platform: 3D, third-person, single-player first with optional co-op (2-4 players). If you want Roblox (Luau), a browser game, or Unity/Unreal, say so and I'll adapt the systems below.

## 2. Elevator pitch

*"A storm is coming. You have 90 seconds of warning, a half-built shelter and a town full of stuff worth grabbing. Read the sky, pick your spot and survive the funnel."*

Pillars:
1. **Dread through readability.** The player can always read the threat (sky colour, wind sound, debris direction) and is never killed by something unfair.
2. **Preparation matters.** What you do before the storm decides how the storm goes.
3. **Physics-driven chaos.** Debris, vehicles and buildings react believably. Every run plays out differently.
4. **Short runs, long progression.** A run lasts 6-12 minutes, and unlocks carry between runs.

## 3. Core gameplay loop

1. **Forecast phase (30-60 s).** Radio and weather map show the storm's category, direction and estimated arrival time.
2. **Prep phase (2-5 min).** Scavenge supplies, board windows, fuel the vehicle, rescue NPCs, choose a shelter.
3. **Warning phase (60-90 s).** Sirens sound, the sky turns green-grey, hail begins. The player makes their final choice: shelter in place or run.
4. **Impact phase (1-3 min).** The tornado passes through. The player survives by staying low, bracing and managing stamina and fear, or by out-driving it.
5. **Aftermath phase (1-3 min).** Search the rubble, treat injuries, rescue survivors and collect rewards.
6. **Meta phase.** Spend currency on upgrades, unlock new maps and gear, then pick the next outbreak.

## 4. The tornado (the star of the game)

### 4.1 Intensity scale
Use an Enhanced-Fujita-style scale (EF0-EF5) as game "tiers":

| Tier | Feel | Typical effects |
|------|------|-----------------|
| EF0-EF1 | Warm-up | Branches, signs and trash cans fly; windows break |
| EF2 | Serious | Roofs peel off, cars slide, trees fall |
| EF3 | Dangerous | Walls collapse, vehicles lift, wooden houses fail |
| EF4 | Devastating | Houses leveled, heavy debris becomes lethal |
| EF5 | Apocalyptic | Only underground shelters survive, ground is stripped |

### 4.2 Behaviour
- **Path.** Spawns as a funnel cloud, touches down, then follows a meandering path with a wobble, a drift and occasional sudden turns. Paths are seeded, so a challenge seed replays identically.
- **Life cycle.** Forming -> mature -> roping out, with changing width and strength over time.
- **Wind field.** A vortex force model: tangential + inward + upward components that fall off with distance. Strength is based on the tier, so mass and drag decide what lifts.
- **Debris cloud.** Objects picked up become hazards while airborne. A cap on active debris keeps performance stable.
- **Variants.** Multi-vortex, rain-wrapped (hard to see), wedge, ropey, and a twin-tornado event.
- **Multiple storms in one outbreak.** A second cell forms mid-run on harder difficulties.

### 4.3 Warnings (fairness)
- Distant rotation visible on the horizon
- Wall cloud, green sky, sudden silence, then the roar
- Radio chatter and siren cadence tied to distance
- Debris starts flying *toward* the funnel, a direction cue for the player

## 5. Player systems

- **Movement.** Walk, sprint (stamina), crouch, prone, vault, swim, climb. Wind pushes the player harder when standing than when crouched or prone.
- **Survival stats.** Health, stamina, fear/panic (affects aim, vision and breathing), temperature, injuries (bleeding, fractures, concussion).
- **Bracing.** Hold a button to brace against solid cover. This reduces knockback and costs stamina.
- **Grab and hold.** Grab pipes, railings and trees to resist the wind, with grip strength decaying over time.
- **Vehicles.** Car, pickup, ATV, storm-chaser van. Fuel, damage, traction and wind lift. They can be wrecked or flipped, and the driver can bail out.
- **Inventory.** Limited slots with weight. Smart choices matter: water, first aid, flashlight, radio, rope, tools, plywood, battery.
- **Radio and phone.** Receive forecasts, call for rescue and tune to hear escalating reports.

## 6. Shelters and building

| Shelter | Cost | Protection | Notes |
|---------|------|-----------|-------|
| Bathtub with mattress | free | Low | Good for EF0-EF2 |
| Interior closet / hallway | free | Low-Med | Walls still fail at EF3+ |
| Basement | free | Med-High | Needs a house with one |
| Storm cellar | medium | High | Dig it during prep |
| Reinforced safe room | high | Very High | Unlockable |
| Community bunker | map-fixed | Highest | Fits many NPCs, may be locked |

- **Fortifying.** Board windows, brace doors, sandbag, anchor furniture, cover vents.
- **Structural simulation.** Buildings have simple structural integrity: roof -> walls -> foundation. Weak points fail first.
- **Dig mode.** Dig a cellar with tools, with a progress bar and noise.

## 7. World and maps

1. **Prairie Town (tutorial).** Flat fields, farmhouse, barn, diner, gas station and a church with a basement.
2. **Trailer Park.** Weak structures, high urgency, a nearby ditch as an option.
3. **Suburbia.** Cul-de-sacs, garages, basements and NPC neighbours to help.
4. **Highway Strip.** Vehicles, overpasses (they are NOT safe, and the game teaches this), truck stop.
5. **Hospital District.** Tough building, patients to evacuate, generator and blackout.
6. **Industrial Yard.** Tankers, shipping containers, cranes, fire and explosion hazards.
7. **Mountain Pass / Lake Town.** Terrain that bends the tornado's path, with boats and docks.
8. **Night Outbreak.** Lightning-only visibility and sirens in the dark.

Each map has: day/night, weather variants (clear, rain, hail, fog), procedurally placed loot, and 2-3 route options.

## 8. NPCs and story

- **Family and neighbours** to rescue (reward: bonus currency, perks)
- **Storm chaser** mentor who provides forecasts and tutorials by radio
- **Radio DJ** gives atmospheric commentary, rumours and a running narrative
- **Hostile-ish NPCs?** Panicked looters who don't help. **[ASSUMPTION]** No combat; tension comes from the storm and from moral choices (save one person or grab supplies).

Light story: a small town hit by a record outbreak season. The player is a local trying to protect their family while the radio hints at a bigger, deadlier storm coming for the finale.

## 9. Game modes

- **Campaign.** 10-15 escalating outbreaks, with story beats between them.
- **Endless / Survival.** Back-to-back storms, scoring by time survived and people saved.
- **Daily Challenge.** Shared seed, global leaderboard.
- **Sandbox.** Spawn tornadoes of any tier, move them and watch buildings fall. Good for streamers.
- **Chaser mode.** Drive a storm-chaser vehicle, place probes in the tornado's path and record data for rewards.
- **Co-op.** 2-4 players with roles: Driver, Medic, Builder, Radio/Scout.

## 10. Progression and economy

- **Currency.** *Cash* (earned from rescues, objectives and data) and *Insight* (XP for the skill tree).
- **Skill tree.** Endurance, Prep (faster boarding/digging), Awareness (longer warning cues), Medic, Driver.
- **Unlocks.** Gear (better flashlight, helmet, gloves), vehicles, shelter blueprints, cosmetics, new maps.
- **Difficulty modifiers.** One-hit down, fog, double storms, limited supplies, no radio. Higher risk = higher reward multiplier.
- **Achievements.** "Cellar Dweller", "Eye of the Storm" (survive inside the calm center on a late tier), "Never Overpass", "Zero Casualties".

## 11. Art direction

- **Look.** Semi-realistic and moody, with a strong colour story: warm gold calm -> sickly green -> dark steel grey -> blinding white rain.
- **Tornado visuals.** Layered volumetric funnel, ground-level dust halo, condensation tube, debris particles with motion blur, lightning flashes inside.
- **Camera.** Subtle shake that scales with proximity, with a "reduce motion" accessibility option.
- **UI.** Minimal diegetic HUD: a wrist radio, a paper map, a heartbeat vignette. A radar/forecast overlay appears only on the radio.

## 12. Audio direction

- Wind with layered pitch rising as the funnel nears, and the "freight train" roar
- Sirens with Doppler and distance filtering
- Creaking timber, glass shattering, metal screeching
- Sudden silence before impact (a signature moment)
- Dynamic music: sparse dread -> percussive panic -> quiet, haunting aftermath
- Radio voice acting with static that gets worse in the storm

## 13. Technical requirements

- **Performance target.** 60 FPS on mid-range hardware, with tunable debris caps and LODs.
- **Physics.** Rigid-body debris with sleeping, pooled objects, spatial hashing for wind queries, and a cheap-far / precise-near split.
- **Destruction.** Pre-fractured props plus modular building pieces with joint breaking.
- **Procedural generation.** Seeded loot, weather, tornado path and NPC placement for fair, shareable runs.
- **Save system.** Meta progression, settings and daily-challenge state.
- **Accessibility.** Colourblind-safe UI, subtitles, motion-sickness options, remappable controls, adjustable fear/tension effects.
- **Networking (co-op).** Authoritative host, replicated tornado seed + time (not per-frame positions), and replicated debris near players only.

## 14. Suggested architecture

```
/game
  /core        game loop, state machine (Forecast/Prep/Warning/Impact/Aftermath)
  /weather     tornado entity, wind field, path generator, sky/lighting controller
  /physics     debris pooling, force application, structural integrity
  /player      movement, stats, bracing, inventory
  /vehicles    handling, fuel, damage
  /world       map loader, loot spawner, NPC spawner
  /ui          HUD, radio, map, menus
  /meta        progression, economy, unlocks, save
  /audio       dynamic mixer, music director
  /tools       seed viewer, tornado sandbox, balance spreadsheet export
```

## 15. Build milestones

1. **Vertical slice:** one flat map, an EF2 tornado with a wind field, one house, bracing, a basement and win/lose states.
2. **Systems pass:** survival stats, inventory, vehicles, structural damage.
3. **Content pass:** 4 maps, all shelter types, NPC rescues, forecast/radio.
4. **Meta pass:** progression, upgrades, daily seed, leaderboards.
5. **Polish:** VFX, audio, accessibility, performance, tutorial.
6. **Stretch:** co-op, chaser mode, night outbreak, workshop/mod support.

## 16. What I want from you first

1. Confirm or fix every **[ASSUMPTION]** above (platform, single-player vs co-op, combat or none).
2. Propose the folder structure and tech stack for my chosen platform.
3. Implement milestone 1 (vertical slice) with clean, commented code.
4. Tell me what you couldn't do and which assets I need to supply.

## 17. Tone and constraints

- Keep the game tense but not gory. Stay respectful about disaster and loss.
- Real-world accuracy is a *flavour*, not a rule. Fun and readability beat strict realism.
- Don't add combat, microtransactions or dark patterns unless I ask.
- Keep code modular, data-driven (tier tables, loot tables and shelter stats in config files) and easy to balance.
