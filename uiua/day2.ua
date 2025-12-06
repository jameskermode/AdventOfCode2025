Input     ← &fras "data/day_2.txt"
Lines     ← ⊜□≠@\n. Input
IdRanges  ← ⊜□≠@,.°□⊢Lines
StartStop ← ≡(⋕ ⊜□≠ @-.°□) IdRanges
Ids       ← /◇⊂ ≡(□ + ⊃⊢ (⇡+1-))°⊟ ⍉ StartStop

PartI ← /+×⟜(≡(≍ °⊟ ⬚∞ ↯ 2_∞ -@0 °⋕)) Ids
&p $"Part 1: _" PartI

# Part 2: check N = 2..7, OR results
CheckN ← =1 ⧻ ◴ ⬚∞↯ ⊓(⇌⊟∞)(-@0 °⋕)
Ns     ← +2⇡6
PartII ← /+ × ⟜(/↥ ⊞CheckN Ns) Ids
&p $"Part 2: _" PartII
