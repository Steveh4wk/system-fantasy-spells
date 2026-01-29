# Fantasy Peds - Lycan/Ice Wolf Integration

## Overview
Complete integration of the Ice Wolf ped into the Fantasy system following the existing Vampire pattern.

## Files Created/Modified

### New Files
- `client/lycan_client.lua` - Main Lycan transformation and spells system
- `client/lycan_init.lua` - Lycan system initialization

### Modified Files
- `fxmanifest.lua` - Added Lycan scripts to client_scripts
- `fantasy_ui/client/menu.lua` - Enhanced Lycan spell integration

## Features

### Transformation Commands
- `/become_ice_wolf` - Transform into Ice Wolf
- `/become_lycan` - Alternative command for Lycan transformation
- `/creatures` - Open creature menu (includes Ice Wolf option)

### Spell System
- `/lycan_spells` - Open Lycan-specific spell menu
- `/spells` - Universal spell menu (includes Lycan spells when transformed)

### Available Lycan Spells
1. **Ululato di Ghiaccio** (Ice Howl)
   - Cooldown: 60 seconds
   - Effect: Increases speed and strength for 30 seconds
   - Description: Powerful howl that enhances physical abilities

2. **Soffio di Gelo** (Frost Breath)
   - Cooldown: 45 seconds
   - Effect: Freezing breath that slows nearby enemies
   - Description: Ice breath with area effect

## Integration Points

### Fantasy Spells System
- Uses `fantasy_spells` exports for werewolf status checking
- Integrates with existing database system
- Supports both direct exports and event-based fallbacks

### Fantasy UI System
- Enhanced spell menu with Lycan-specific styling
- Proper cooldown management
- Integrated with universal spell system

### Fantasy Peds System
- Uses shared creature state management
- Integrates with original state saving/restoration
- Supports transformation cleanup

## Ped Configuration

### Metadata Location
- `stream/Lycan/peds.meta` - Contains Ice Wolf ped definition

### Ped Files
- `Ice Wolf.yft` - Model file
- `Ice Wolf.ymt` - Model metadata
- `Ice Wolf.ytd` - Texture dictionary
- `Ice Wolf.ydd` - Drawable dictionary

### Model Configuration
```xml
<Item>
    <Name>Ice Wolf</Name>
    <ModelName>IceWolf</ModelName>
    <Pedtype>CIVMALE</Pedtype>
    <MovementClipSet>move_m@alien</MovementClipSet>
    <DefaultTaskData>
        <TaskDataName>STANDARD_PED</TaskDataName>
    </DefaultTaskData>
    <RelationshipGroup>PLAYER</RelationshipGroup>
    <IsStreamedGfx value="true"/>
</Item>
```

## Usage Instructions

1. **Player Transformation**: Use `/become_ice_wolf` or `/creatures` menu
2. **Spell Access**: Use `/lycan_spells` or `/spells` when transformed
3. **Revert Human**: Use `/creatures` menu and select "Torna Umano"

## Technical Details

### State Management
- Uses `creatureStates.isIceWolf` for tracking transformation
- Integrates with `CreatureSystem` for state persistence
- Supports proper cleanup and restoration

### Cooldown System
- Local cooldown tracking in `lycan_client.lua`
- Exports cooldown functions for `fantasy_ui` integration
- Persistent across transformation cycles

### Event System
- Supports both direct exports and event-based communication
- Fallback mechanisms for robust operation
- Proper event handler cleanup

## Dependencies
- `ox_lib` - UI framework
- `qb-core` - Core framework
- `fantasy_spells` - Spell management system
- `fantasy_ui` - Universal spell menu

## Notes
- Ice Wolf uses the same model name as defined in peds.meta: `IceWolf`
- Transformation includes visual effects and base speed increase
- Full integration with existing Fantasy ecosystem
- Follows established patterns from Vampire implementation
