### 2025-09-23-layout-bigArray.json

| Candidate | Runs | Mean (s) | Median (s) | StdDev (s) | Min (s) | Max (s) | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | :--- |
| baseline | 24 | 1.7609 | 1.7539 | 0.0629 | 1.6545 | 1.9331 |  |
| anneal | 24 | 1.7419 | 1.7313 | 0.0797 | 1.6348 | 1.9316 |  |

Welch's t-test (anneal vs baseline): t = 0.915, dof = 43.6, p = 0.365 (not significant).
Mean delta: -0.0190s (-1.08%).


### 2025-09-23-layout-bigObject.json

| Candidate | Runs | Mean (s) | Median (s) | StdDev (s) | Min (s) | Max (s) | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | :--- |
| baseline | 12 | 4.0396 | 4.0181 | 0.1248 | 3.8536 | 4.2348 |  |
| anneal | 12 | 4.0367 | 3.9581 | 0.2162 | 3.7725 | 4.5206 |  |

Welch's t-test (anneal vs baseline): t = 0.040, dof = 17.6, p = 0.969 (not significant).
Mean delta: -0.0029s (-0.07%).


### 2025-09-23-layout-chess_bm.json

| Candidate | Runs | Mean (s) | Median (s) | StdDev (s) | Min (s) | Max (s) | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | :--- |
| baseline | 12 | 7.6691 | 7.4507 | 0.4654 | 7.3202 | 8.9290 |  |
| anneal | 0 | n/a | n/a | n/a | n/a | n/a | 1 failure(s) |

Anneal candidate encountered failures; statistical comparison skipped.


### 2025-09-23-layout-navierStokes_bm.json

| Candidate | Runs | Mean (s) | Median (s) | StdDev (s) | Min (s) | Max (s) | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | :--- |
| baseline | 12 | 4.0444 | 4.0029 | 0.1764 | 3.8759 | 4.4771 |  |
| anneal | 0 | n/a | n/a | n/a | n/a | n/a | 1 failure(s) |

Anneal candidate encountered failures; statistical comparison skipped.

