extends Node

# Store and manage high level signals

@warning_ignore_start("unused_signal")

# card handling
signal discard(card: Card) # emitted by selected cards, read by game manager
signal reroll(card: Card) # emitted by selected cards, read by game manager
signal card_tapped(card: Card) # emitted by card, read by game manager
signal pile_empty(pile: Pile) # emitted by piles, read by game manager

# State Machines
signal customer_done_moving # emitted by customer, read by order machine
signal all_orders_completed # emitted by order machine, ready by game manager

# GUI
# might rename to bell rung, if ui matches
signal serve_pressed() # emitted by hud, read by game manager
signal time_ran_out() # emittd by gametimer
signal time_penalty(value: float) # emitted by game manager, read by game timer
signal restart_day # Emitted by fail screen
signal view_pack(cards: Array[Variant]) # Emitted by piles and packs

# dialog
signal queue_textbox(text: String) # (todo) emitted by cutscene scenes, read by dialog box
