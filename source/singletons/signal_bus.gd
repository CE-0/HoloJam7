extends Node

# Store and manage high level signals

@warning_ignore_start("unused_signal")

# card handling
signal discard(card: Card) # emitted by selected cards, read by game manager?
signal pile_empty(pile: Pile) # emitted by piles, read by game manager?
signal card_tapped(card: Card) # emitted by card, read by game manager

# GUI
signal serve_pressed() # emitted by hud, read by game manager

# dialog
signal queue_textbox(text: String) # (todo) emitted by cutscene scenes, read by dialog box
