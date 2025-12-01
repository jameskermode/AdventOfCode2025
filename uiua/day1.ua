Lines ← ⊜□≠@\n.
Input ← Lines &fras "data/day_1.txt"

Signs  ← ≡((˜ⁿ ¯1 =@L⊢)°□) Input
Counts ← ≡((⋕ ↘ 1)°□) Input

PartI ← /+=0↘ 1\(◿ 100+) ⊂50 × Signs Counts
&p $"Part 1: _" PartI

PartII ← /+ =0 ↘ 1 ◿ 100 \+ ⊂ 50 ▽ Counts Signs
&p $"Part 2: _" PartII
