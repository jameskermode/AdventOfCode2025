Input     ← &fras "data/day_2_test.txt"
Lines     ← ⊜□≠@\n. Input
IdRanges  ← ⊜□≠@,.°□⊢Lines
StartStop ← ≡(⋕ ⊜□≠ @-.°□) IdRanges
Ids       ← /◇⊂ ≡(□ + ⊃⊢ (⇡+1-))°⊟ ⍉ StartStop

PartI ← /+×⟜(≡(≍ °⊟ ⬚∞ ↯ 2_∞ -@0 °⋕)) Ids
&p $"Part 1: _" PartI
