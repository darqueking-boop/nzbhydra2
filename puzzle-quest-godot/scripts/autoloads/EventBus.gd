extends Node

## Central signal bus for decoupled communication between game systems.

# Board signals
signal match_found(gems: Array, gem_type: int)
signal gems_cleared(count: int, gem_type: int)
signal board_resolved()
signal swap_attempted(from: Vector2i, to: Vector2i, success: bool)

# Combat signals
signal damage_dealt(target: String, amount: int, element: int)
signal mana_gained(color: int, amount: int)
signal spell_cast(caster: String, spell_id: String)
signal unit_died(unit_id: String)
signal combat_started(player_data: Dictionary, enemy_data: Dictionary)
signal combat_ended(victory: bool)
signal turn_changed(is_player_turn: bool)

# UI signals
signal score_changed(new_score: int)
signal xp_gained(amount: int)
signal level_up(new_level: int)
signal quest_completed(quest_id: String)

# Navigation signals
signal scene_change_requested(scene_path: String)
