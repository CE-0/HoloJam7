extends Node

# Store and manage high level signals

@warning_ignore_start("unused_signal")

# card handling
signal discard(card: Card) # emitted by selected cards, read by game manager?
signal pile_empty(pile: Pile) # emitted by piles, read by game maanger?

# dialog
signal queue_textbox(text: String) # (todo) emitted by cutscene scenes, read by dialog box
