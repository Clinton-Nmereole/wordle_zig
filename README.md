## Goal of Project
This is an attempt to create a wordle game in Zig and subsequently a wordle solver.

## What is wordle
Wordle is a web-based word game where players have six attempts to guess a five-letter word, with feedbackgiven for each guess in the form of colored tiles indicating when letters match or occupy the correct position.

## Naive Implementation
1. Download a wordle dictionary containing most of the five-letter words used in wordle.
2. Make a Trie data structure that can be used to store the words from the dictionary.txt file
3. Make a wordle board by making a 6x5 array of nullable u8 values.
