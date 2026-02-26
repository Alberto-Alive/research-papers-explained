This note explains **“Optimal Bounds for Open Addressing Without Reordering”** by **Martin Farach-Colton, Andrew Krapivin, and William Kuszmaul, and the original can be found on **arXiv** (arXiv:2501.02305). ([arXiv][1])

[1]: https://arxiv.org/abs/2501.02305?utm_source=chatgpt.com "Optimal Bounds for Open Addressing Without Reordering"



I will refer to the baseline as greedy and to this paper as elastic hashing:

Memory is split into levels Ai (i goes from 1 to k).

greedy: for a key x, it keeps probing along x’s order and takes the first free slot it hits.
If Ai is very full, the first free slot for x might be at a large j, so x ends up stored “deep” → slower to find later.

elastic hashing: it probes only a small / bounded number of j candidates in Ai.
If it doesn’t find a free slot fast, it moves to Ai+1 and inserts there (where it’s more likely to find a free slot at small j).

= this helps storing info at lower j (smaller search position) than greedy does, because it’s willing to give up early on a packed level instead of digging deep inside it.

Critical / expensive case: elastic hashing basically forces the insertion decision to be between two levels: Ai and Ai+1. If Ai is almost full (e.g., 99%) and Ai+1 is “too full” (≥75% full), then elastic hashing refuses to place in Ai+1 (because then it can’t reliably get small j there anymore). So it forces insertion back into Ai, and then it may have to probe a lot of j’s in Ai until it finds the rare empty → that’s why this case is expensive (but it’s designed to be rare).