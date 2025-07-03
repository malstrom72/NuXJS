/*
	Priyome Chess Computer by Magnus Lidström.
	
	Priyome is a complete chess computer in single plain C source code file. It was written to be easily ported to
	other even more primitive languages. E.g. it uses only varegers and does not require structures. The AI is
	implemented using standard chess computer techniques such as alpha beta pruning search with iterative deepening,
	quiescence optimization (only checking for captures beyond a specific depth) and a memory efficient solution for
	transposition table lookup. (See comment in source code below.)

	It was not designed to be the best chess computer in the world, but still put up a strong fight against any human
	player. The primary objective is a clean and portable source code.

	It is important to compile this code with NDEBUG defined for release builds. Due to the massive invariance testing,
	the code is extremely slow otherwise.

	Priyome is released under the "New Simplified BSD License". http://www.opensource.org/licenses/bsd-license.php

	Copyright (c) 2013-2014, NuEdge Development / Magnus Lidstroem
	All rights reserved.

	Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
	following conditions are met:

	Redistributions of source code must retain the above copyright notice, this list of conditions and the following
	disclaimer. 
	
	Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
	disclaimer in the documentation and/or other materials provided with the distribution. 
	
	Neither the name of the NuEdge Development nor the names of its contributors may be used to endorse or promote
	products derived from this software without specific prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS varERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
	OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*
	FUTURE

	Idea: reimplement extra recapture stage (after standard quiescence we check only pieces that move to the exact
	target square of previous ply). We should do this with a quicker reverse lookup from captured piece instead of
	trying every possible attacking piece. Also, this reverse lookup could be used to speed up standard quiescence when
	there are fewer pieces to capture than attacking pieces.
*/

/* Using enum to define constants instead of #define. You can't use "const var" in C, only in C++. */

"use strict";

var DEBUG = false;

var GLOBALS = this;

var STRIDE = (8 + 2);
var BOARD_SIZE = (8 + 4) * STRIDE;
var RANK_1 = STRIDE * 2;
var RANK_2 = STRIDE * 3;
var RANK_3 = STRIDE * 4;
var RANK_4 = STRIDE * 5;
var RANK_5 = STRIDE * 6;
var RANK_6 = STRIDE * 7;
var RANK_7 = STRIDE * 8;
var RANK_8 = STRIDE * 9;

var OFFBOARD = -1;
var EMPTY = 0;
var PAWN = 1;
var ROOK = 2;
var KNIGHT = 3;
var BISHOP = 4;
var QUEEN = 5;
var KING = 6;
var BLACK = 8;
var WHITE = 16;										/* We use two bits for color. 00 = empty, 01 = black, 10 = white, 11 = off-board. This allows fast bit-tricks for tracing possible moves. E.g. (... & color) == 0 to check if a square is empty or contains an opponent piece. */
var PIECE_MASK = 7;
var COLOR_MASK = BLACK | WHITE;
var COLOR_SWITCH_XOR = BLACK ^ WHITE;
var MOVED_MASK = 32;								/* The moved bit helps us determine if a king can castle or not and also if a pawn is allowed to move two squares. */
var PIECE_AND_MOVED_MASK = PIECE_MASK | MOVED_MASK;

var MIN_DEPTH = 4;
var MAX_DEPTH = 16;
var QUIESCENCE_DEPTH = 8;
var TO_SHIFT = 8;
var SCORE_SHIFT = 16;
var MOVE_MASK = 0x0000FFFF;
var FROM_MASK = 0x000000FF;
var TO_MASK = 0x0000FF00;
var SCORE_MASK = ~MOVE_MASK;
var CHECKMATE = 0xFFFF;
var STALEMATE = 0xFFFE;
var IN_CHECK = 0xFFFD;
var VALID_MOVE = 0xFFFC;
var INVALID_MOVE = -1;
var MAX_SCORE = 10000;
var MIN_SCORE = -MAX_SCORE;
var PAWN_VALUE = 100;
var QUEEN_VALUE = 9 * PAWN_VALUE;
var PROMOTION_SCORE = QUEEN_VALUE - PAWN_VALUE;
var CAPTURE_KING_MIN_SCORE = MAX_SCORE - MAX_DEPTH;
var RANDOM_AMOUNT = ~~(PAWN_VALUE / 10);
var PAWN_ADVANCE_SCORE = ~~(PAWN_VALUE / 10);
var CASTLING_SCORE = ~~(PAWN_VALUE / 2);
var CASTLING_MASK = 0x80; 								/* Used for xCapture */
var HISTORY_SIZE = 256;

var DIRS = [ STRIDE, STRIDE + 1, 1, -STRIDE + 1, -STRIDE, -STRIDE - 1, -1, STRIDE - 1 ];
var KNIGHT_MOVES = [ STRIDE * 2 + 1, 2 + STRIDE, 2 - STRIDE, -STRIDE * 2 + 1, -STRIDE * 2 - 1, -STRIDE - 2, STRIDE - 2, STRIDE * 2 - 1 ];
var PIECE_VALUES = [ 0, PAWN_VALUE, 5 * PAWN_VALUE, 3 * PAWN_VALUE, 3 * PAWN_VALUE, QUEEN_VALUE, MAX_SCORE ];
var RANK_VALUES = [ 0, 0, 0, 30, 50, 60, 60, 50, 30, 0, 0, 0 ]; 	/* Simple score structure used for all pieces but pawns. */

var MAX_TARGET_SQUARES = 32; 	/* Max target squares for a single piece. */
var MAX_MOVES = 256;			/* Max psuedo-legal moves from any given position. 256 should be enough for any normal game. Prove me wrong. */
var MAX_CAPTURES = 32;			/* Max pseudo-legal captures from any given position. 32 should be enough for any normal game. Prove me wrong. */

/* Notice the flipped effect because we have the lowest rank first in the array. */
var INIT_BOARD = [
	OFFBOARD,	OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,
	OFFBOARD,	OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,
	OFFBOARD,	ROOK | WHITE,	KNIGHT | WHITE,	BISHOP | WHITE,	QUEEN | WHITE,	KING | WHITE,	BISHOP | WHITE,	KNIGHT | WHITE,	ROOK | WHITE,	OFFBOARD,
	OFFBOARD,	PAWN | WHITE,	PAWN | WHITE,	PAWN | WHITE,	PAWN | WHITE,	PAWN | WHITE,	PAWN | WHITE,	PAWN | WHITE,	PAWN | WHITE,	OFFBOARD,
	OFFBOARD,	EMPTY,			EMPTY,			EMPTY,			EMPTY,			EMPTY,			EMPTY,			EMPTY,			EMPTY,			OFFBOARD,
	OFFBOARD,	EMPTY,			EMPTY,			EMPTY,			EMPTY,			EMPTY,			EMPTY,			EMPTY,			EMPTY,			OFFBOARD,
	OFFBOARD,	EMPTY,			EMPTY,			EMPTY,			EMPTY,			EMPTY,			EMPTY,			EMPTY,			EMPTY,			OFFBOARD,
	OFFBOARD,	EMPTY,			EMPTY,			EMPTY,			EMPTY,			EMPTY,			EMPTY,			EMPTY,			EMPTY,			OFFBOARD,
	OFFBOARD,	PAWN | BLACK,	PAWN | BLACK,	PAWN | BLACK,	PAWN | BLACK,	PAWN | BLACK,	PAWN | BLACK,	PAWN | BLACK,	PAWN | BLACK,	OFFBOARD,
	OFFBOARD,	ROOK | BLACK,	KNIGHT | BLACK,	BISHOP | BLACK,	QUEEN | BLACK,	KING | BLACK,	BISHOP | BLACK,	KNIGHT | BLACK,	ROOK | BLACK,	OFFBOARD,
	OFFBOARD,	OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,
	OFFBOARD,	OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD,		OFFBOARD
];

var PIECE_CHARS = " PRNBQK  prnbqk ";
var PIECE_NAMES = [ "", "pawn", "rook", "knight", "bishop", "queen", "king" ];

function fillArray(a, value) {
	for (var i = 0; i < a.length; ++i) a[i] = value;
	return a;
}

function create1DArray(dim, initValue) {
	return fillArray(new Array(dim), initValue);
};

var board = create1DArray(BOARD_SIZE, 0);
var nextPiece = create1DArray(BOARD_SIZE, 0);
var prevPiece = create1DArray(BOARD_SIZE, 0);
var xCapture = 0;
var turnColor = 0;
var boardHash = 0;

/*
	Unlike most transposition table implementations our hash table is used only for improving move ordering based on
	the outcome of previous searches. This greatly reduces processing time due to alpha beta pruning. It is sufficient
	with a fairly small table (minimum is 64k entries). A bigger table (say 1M entries) gives marginally better results
	with deeper searches. The hash table contains 32-bit vars where the higher 16 bits are the highest 16 bits of the
	hash key (used to minimize collisions) and the lower 16 bits define the last chosen move for this particular
	position.

	Hashes for positions are incrementally updated with a Zobrist mechanism using a table with random values for each
	piece (incl colors and moved bits) and square + xCapture and turnColor values. We bit-and all hash operations with
	~0 to emphasize the "wrapping" of additions and subtractions.

	The advantage of this solution compared to a standard transposition table with exact search results are simplicity
	(no structs needed), reliablitiy (collisions are harmless) and memory footprint.
*/
var HASH_TABLE_SIZE = 64 * 1024;
var HASH_MASK = ~0;

var pieceKeys = create1DArray(BOARD_SIZE * 64, 0);
var xCaptureKeys = create1DArray(256, 0);
var colorKeys = create1DArray(WHITE + 1, 0);
var hashTable = create1DArray(HASH_TABLE_SIZE, 0);
var evalCounter = 0;
var chessHistory = create1DArray(HISTORY_SIZE * 4, 0);		/* Four elements per half-move: 16-bit move, piece, captured and xCapture (see doMove() for more info). */
var historyCount = 0;
var minEvals = 10000;

var randPX = 123456789;
var randPY = 362436069;

function nextRandom() {

	/* Marsaglia's Xorshift PRNG algorithm. */
	
	var t = (randPX ^ (randPX << 10)) & 0xFFFFFFFF;
	randPX = randPY;
	randPY = (randPY ^ (randPY >>> 13) ^ t ^ (t >>> 10)) & 0xFFFFFFFF;
	return randPY;
}

function initGlobals() {	
	/*
		The xor-shift random algorithm makes it necessary to use addition and subtraction for the incremental Zobrist
		hashing instead of xor.
	*/
	
	var i;
	for (i = 0; i < 64 * BOARD_SIZE; ++i) {
		pieceKeys[i] = nextRandom();
	}
	for (i = 0; i < 256; ++i) {
		xCaptureKeys[i] = nextRandom();
	}
	colorKeys[WHITE] = nextRandom();
	colorKeys[BLACK] = nextRandom();
}

function isOnBoard(square) {
	return (square >= 0 && square < BOARD_SIZE && INIT_BOARD[square] != OFFBOARD);
}

function isValidColor(color) {
	return (color == WHITE || color == BLACK);
}

function isValidMove(move) {
	return ((move & MOVE_MASK) == move && isOnBoard(move & FROM_MASK) && isOnBoard((move & TO_MASK) >> TO_SHIFT));
}

function isValidPiece(piece) {
	return (1 <= piece && piece < 64 && (piece & PIECE_MASK) >= 1 && (piece & PIECE_MASK) <= 6
			&& isValidColor(piece & COLOR_MASK));
}

function moveFrom(move) {
	if (DEBUG) assert(isValidMove(move));
	return (move & FROM_MASK);
}

function moveTo(move) {
	if (DEBUG) assert(isValidMove(move));
	return move >> TO_SHIFT;
}

function makeMove(fromCol, fromRow, toCol, toRow) {
	return ((fromRow + 2) * STRIDE + fromCol + 1) | (((toRow + 2) * STRIDE + toCol + 1) << TO_SHIFT);
}

function switchColor(color) {
	return color ^ COLOR_SWITCH_XOR;
}

function checkInvariant() {
	var color, h, i, counts = create1DArray((BLACK | WHITE) + 1, 0), countsAgain = create1DArray((BLACK | WHITE) + 1, 0);

	assert(isValidColor(turnColor));

	if (xCapture != 0) {
		assert(0 <= xCapture && xCapture < 256);
		assert(isOnBoard(xCapture & ~128));
		
		if (((xCapture & CASTLING_MASK) != 0)) {
			assert((board[xCapture & ~CASTLING_MASK] & PIECE_AND_MOVED_MASK) == (ROOK | MOVED_MASK));
			assert((board[(xCapture & ~CASTLING_MASK) - 1] & PIECE_AND_MOVED_MASK) == (KING | MOVED_MASK)
					|| (board[(xCapture & ~CASTLING_MASK) + 1] & PIECE_AND_MOVED_MASK) == (KING | MOVED_MASK));
		} else {
			assert((xCapture >= RANK_3 && xCapture < RANK_4) || (xCapture >= RANK_6 && xCapture < RANK_7));
			assert(board[xCapture + STRIDE] == (WHITE | PAWN | MOVED_MASK)
					|| board[xCapture - STRIDE] == (BLACK | PAWN | MOVED_MASK));
		}
	}
	
	color = BLACK;
	do {
		var from = nextPiece[color];
		counts[color] = 0;
		while (from != color) {
			var p = board[from];
			assert((p & COLOR_MASK) == color);
			assert(isValidPiece(p));
			from = nextPiece[from];
			++counts[color];
		}
		color = switchColor(color);
	} while (color != BLACK);
	
	h = 0;
	countsAgain[BLACK] = countsAgain[WHITE] = 0;
	for (i = 0; i < BOARD_SIZE; ++i) {
		var p = board[i];
		assert(INIT_BOARD[i] != OFFBOARD || p == OFFBOARD);
		if (p > EMPTY) {
			assert(isValidPiece(p));
			assert(0 <= p && p < 64);
			h = (h + pieceKeys[i * 64 + p]) & HASH_MASK;
		}
		++countsAgain[p & COLOR_MASK];
	}
	
	assert(countsAgain[BLACK] == counts[BLACK]);
	assert(countsAgain[WHITE] == counts[WHITE]);
	assert(h == boardHash);
	
	return true;
}

function putPiece(square, piece) {
	var c, n;

	if (DEBUG) assert(isOnBoard(square));
	if (DEBUG) assert(isValidPiece(piece));
	
	if (DEBUG) assert(board[square] == EMPTY);
	board[square] = piece;
	c = piece & COLOR_MASK;
	n = nextPiece[c];
	nextPiece[square] = n;
	prevPiece[square] = c;
	prevPiece[n] = square;
	nextPiece[c] = square;
	boardHash = (boardHash + pieceKeys[square * 64 + piece]) & HASH_MASK;
}

function liftPiece(square) {
	var piece, n, p;

	if (DEBUG) assert(isOnBoard(square));
	
	piece = board[square];
	if (DEBUG) assert(piece > EMPTY);
	boardHash = (boardHash - pieceKeys[square * 64 + piece]) & HASH_MASK;
	board[square] = EMPTY;
	n = nextPiece[square];
	p = prevPiece[square];
	nextPiece[p] = n;
	prevPiece[n] = p;
}

function movePiece(from, to, newPiece) {
	var oldPiece, n, p;

	if (DEBUG) assert(isOnBoard(from));
	if (DEBUG) assert(isOnBoard(to));
	if (DEBUG) assert(isValidPiece(newPiece));
	if (DEBUG) assert(from != to);	
	if (DEBUG) assert(board[to] == EMPTY);
	
	board[to] = newPiece;
	oldPiece = board[from];
	if (DEBUG) assert(isValidPiece(oldPiece));
	boardHash = (boardHash + pieceKeys[to * 64 + newPiece] - pieceKeys[from * 64 + oldPiece]) & HASH_MASK;
	board[from] = EMPTY;
	n = nextPiece[from];
	p = prevPiece[from];
	prevPiece[to] = p;
	nextPiece[to] = n;
	nextPiece[p] = to;
	prevPiece[n] = to;
}

function restart() {
	var i;

	nextPiece[WHITE] = prevPiece[WHITE] = WHITE;
	nextPiece[BLACK] = prevPiece[BLACK] = BLACK;
	boardHash = 0;
	for (i = 0; i < BOARD_SIZE; ++i) {
		board[i] = EMPTY;
		if (INIT_BOARD[i] == OFFBOARD) {
			board[i] = OFFBOARD;
		} else if (INIT_BOARD[i] > EMPTY) {
			putPiece(i, INIT_BOARD[i]);
		}
	}
	for (i = 0; i < HASH_TABLE_SIZE; ++i) {
		hashTable[i] = 0;
	}
	turnColor = WHITE;
	xCapture = 0;
	historyCount = 0;
	if (DEBUG) assert(checkInvariant());
}

function squareCapturesCastlingKing(square) {

	/*
		On the ply immediately following castling, xCapture will contain the rook's square (+ CASTLING_MASK) and any
		move to this square or the horizontally adjacent squares are varerpreted as capturing the king in order to
		prevent illegal castling.
	*/
	
	return ((square | CASTLING_MASK) >= xCapture - 1 && (square | CASTLING_MASK) <= xCapture + 1);
}

function squareCapturesKing(square) {
	if (DEBUG) assert(isOnBoard(square));

	return ((board[square] & PIECE_MASK) == KING || squareCapturesCastlingKing(square));
}

/*
	doMove() could have returned all required data for undoMove() but in order to avoid language dependent constructs
	for returning multiple vars (such as structs and povarers), you setup the necessary undo data before calling
	doMove() instead. Like this:

	var oldPiece = board[from];
	var captured = board[to];
	var oldXCapture = xCapture;

	Then use the same arguments for undoMove()

	doMove returns the differential score for this move, including a small random amount to avoid repetition.
*/

function doMove(from, to, oldPiece, captured, oldXCapture) {
	var newPiece, score;

	if (DEBUG) assert(isOnBoard(from));
	if (DEBUG) assert(isOnBoard(to));
	if (DEBUG) assert(isValidPiece(oldPiece));
	if (DEBUG) assert(captured == EMPTY || isValidPiece(captured));
	if (DEBUG) assert(from != to);

	if (DEBUG) assert(checkInvariant());
	
	newPiece = oldPiece;
	score = (nextRandom() & 7) - 4;	
	xCapture = 0;

	switch (oldPiece) {
		case KING | WHITE: {
			switch (to) {
				case RANK_1 + 3: {
					
					/* White castling queenside */

					movePiece(RANK_1 + 1, RANK_1 + 4, ROOK | WHITE | MOVED_MASK);
					xCapture = (RANK_1 + 4) | CASTLING_MASK;
					score += CASTLING_SCORE;
					break;
				}
				
				case RANK_1 + 7: {

					/* White castling kingside */

					movePiece(RANK_1 + 8, RANK_1 + 6, ROOK | WHITE | MOVED_MASK);
					xCapture = (RANK_1 + 6) | CASTLING_MASK;
					score += CASTLING_SCORE;
					break;
				}
				
				default: {
					score += RANK_VALUES[~~(to / STRIDE)] - RANK_VALUES[~~(from / STRIDE)];
					break;
				}
			}
			break;
		}
		
		case KING | BLACK: {
						
			switch (to) {
				case RANK_8 + 3: {

					/* Black castling queenside */

					movePiece(RANK_8 + 1, RANK_8 + 4, ROOK | BLACK | MOVED_MASK);
					xCapture = (RANK_8 + 4) | CASTLING_MASK;
					score += CASTLING_SCORE;
					break;
				}
				
				case RANK_8 + 7: {

					/* Black castling kingside */

					movePiece(RANK_8 + 8, RANK_8 + 6, ROOK | BLACK | MOVED_MASK);
					xCapture = (RANK_8 + 6) | CASTLING_MASK;
					score += CASTLING_SCORE;
					break;
				}
				
				default: {
					score += RANK_VALUES[~~(to / STRIDE)] - RANK_VALUES[~~(from / STRIDE)];
					break;
				}
			}			
			break;
		}
		
		case PAWN | WHITE | MOVED_MASK: {
			if (to == oldXCapture) {
				
				/* En passant capture black pawn */
				
				if (DEBUG) assert(board[to - STRIDE] == (PAWN | BLACK | MOVED_MASK));
				liftPiece(to - STRIDE);
				score += PAWN_ADVANCE_SCORE + PAWN_VALUE;
				
			} else if (to >= RANK_8) {
				
				/* Promotion (always to white queen) */
				
				newPiece = QUEEN | WHITE | MOVED_MASK;
				score += PROMOTION_SCORE;
				
			} else {
				score += PAWN_ADVANCE_SCORE;
			}
			break;
		}
		
		case PAWN | BLACK | MOVED_MASK: {
			if (to == oldXCapture) {
			
				/* En passant capture white pawn */
			
				if (DEBUG) assert(board[to + STRIDE] == (PAWN | WHITE | MOVED_MASK));
				liftPiece(to + STRIDE);
				score += PAWN_ADVANCE_SCORE + PAWN_VALUE;
			} else if (to < RANK_2) {
			
				/* Promotion (always to black queen) */
				
				newPiece = QUEEN | BLACK | MOVED_MASK;
				score += PROMOTION_SCORE;
				
			} else {
				score += PAWN_ADVANCE_SCORE;
			}
			break;
		}
		
		case PAWN | WHITE: {
			if (to >= RANK_4) {
				
				/* Register en passant capture square (white) */
				
				xCapture = to - STRIDE;	
				score += PAWN_ADVANCE_SCORE;
			}
			score += PAWN_ADVANCE_SCORE;
			break;
		}
		
		case PAWN | BLACK: {
			if (to < RANK_6) {
				
				/* Register en passant capture square (black) */
				
				xCapture = to + STRIDE;
				score += PAWN_ADVANCE_SCORE;
			}
			score += PAWN_ADVANCE_SCORE;
			break;
		}

		default: {
			score += RANK_VALUES[~~(to / STRIDE)] - RANK_VALUES[~~(from / STRIDE)];
			break;
		}
	}
	
	if (captured > EMPTY) {
		liftPiece(to);
	}
	movePiece(from, to, newPiece | MOVED_MASK);
	
	/*
		Capturing gives a score based on piece type and rank. Without including rank, the computer would value moves
		that end in definite captures just for the score from the move itself.
	*/
	
	switch (captured & (PIECE_MASK | COLOR_MASK)) {
		case EMPTY: break;
		
		case PAWN | WHITE: {
			score += PAWN_VALUE + (~~(to / STRIDE) - 3) * PAWN_ADVANCE_SCORE;
			break;
		}
		
		case PAWN | BLACK: {
			score += PAWN_VALUE + (8 - ~~(to / STRIDE)) * PAWN_ADVANCE_SCORE;
			break;
		}
		
		default: {
			score += PIECE_VALUES[captured & PIECE_MASK] + RANK_VALUES[~~(to / STRIDE)];
			break;
		}
	}
	
	turnColor = switchColor(turnColor);
	
	if (DEBUG) assert(checkInvariant());
	
	return score;
}

/* See doMove() for parameters. */

function undoMove(from, to, oldPiece, captured, oldXCapture) {
	if (DEBUG) assert(isOnBoard(from));
	if (DEBUG) assert(isOnBoard(to));
	if (DEBUG) assert(isValidPiece(oldPiece));
	if (DEBUG) assert(captured == EMPTY || isValidPiece(captured));
	if (DEBUG) assert(from != to);

	if (DEBUG) assert(checkInvariant());

	xCapture = oldXCapture;
	putPiece(from, oldPiece);
	liftPiece(to);
	if (captured > EMPTY) {
		putPiece(to, captured);
	}
	
	switch (oldPiece) {
		case KING | WHITE: {
			switch (to) {
				case RANK_1 + 3: {
					
					/* Undo white castling queenside */

					movePiece(RANK_1 + 4, RANK_1 + 1, ROOK | WHITE);
					break;
				}
				
				case RANK_1 + 7: {

					/* Undo white castling kingside */

					movePiece(RANK_1 + 6, RANK_1 + 8, ROOK | WHITE);
					break;
				}
			}
			break;
		}
		
		case KING | BLACK: {
			switch (to) {
				case RANK_8 + 3: {
				
					/* Undo black castling queenside */

					movePiece(RANK_8 + 4, RANK_8 + 1, ROOK | BLACK);
					break;
				}
				
				case RANK_8 + 7: {

					/* Undo black castling kingside */

					movePiece(RANK_8 + 6, RANK_8 + 8, ROOK | BLACK);
					break;
				}
			}
			break;
		}
		
		case PAWN | WHITE | MOVED_MASK: {
			if (to == oldXCapture) {
			
				/* Undo en passant capture (white) */
				
				putPiece(to - STRIDE, PAWN | BLACK | MOVED_MASK);
			}
			break;
		}
		
		case PAWN | BLACK | MOVED_MASK: {
			if (to == oldXCapture) {
			
				/* Undo en passant capture (black) */

				putPiece(to + STRIDE, PAWN | WHITE | MOVED_MASK);
			}
			break;
		}
	}

	turnColor = switchColor(turnColor);

	if (DEBUG) assert(checkInvariant());
}

function traceRBQ(color, from, toCount, tos, start, step) {
	var cx, d;

	if (DEBUG) assert(isOnBoard(from));

	/* Notice how we don't check squareCapturesCastlingKing() because we will stop tracing at first / last rank anyhow.*/

	cx = switchColor(color);
	for (d = start; d < 8; d += step) {
		var toInc = DIRS[d];
		var to;
		for (to = from + toInc; board[to] == EMPTY; to += toInc) {
			tos[toCount++] = to;
		}
		if ((board[to] & COLOR_MASK) == cx) {
			tos[toCount++] = to;
		}
	}
	return toCount;
}

function listMoves(color, from, tos) {
	var toCount, to, piece, cx;

	if (DEBUG) assert(isOnBoard(from));

	toCount = 0;
	piece = board[from];
	switch (piece & PIECE_MASK) {
		case PAWN: {
			var s = (color == BLACK ? -STRIDE : STRIDE);
			to = from + s;
			if (board[to] == EMPTY) {
				tos[toCount++] = to;
				if ((piece & MOVED_MASK) == 0 && board[to + s] == EMPTY) {
					tos[toCount++] = to + s;
				}
			}
			cx = switchColor(color);
			--to;
			if ((board[to] & COLOR_MASK) == cx || xCapture == to || squareCapturesCastlingKing(to)) {
				tos[toCount++] = to;
			}
			to += 2;
			if ((board[to] & COLOR_MASK) == cx || xCapture == to || squareCapturesCastlingKing(to)) {
				tos[toCount++] = to;
			}
			break;
		}
		
		case ROOK: toCount = traceRBQ(color, from, toCount, tos, 0, 2); break;
		case BISHOP: toCount = traceRBQ(color, from, toCount, tos, 1, 2); break;
		case QUEEN: toCount = traceRBQ(color, from, toCount, tos, 0, 1); break;
		
		case KING: {

			/* Notice how we don't check squareCapturesCastlingKing() because we will stop tracing at first / last rank anyhow. */
	
			var d;
			for (d = 0; d < 8; ++d) {
				to = from + DIRS[d];
				if ((board[to] & color) == 0) {
					tos[toCount++] = to;
				}
			}
			if ((piece & MOVED_MASK) == 0) {
				
				/* Castling */
				
				to = (color == BLACK ? RANK_8 : RANK_1);
				if ((board[to + 2] | board[to + 3] | board[to + 4]) == EMPTY
						&& (board[to + 1] & PIECE_AND_MOVED_MASK) == ROOK) {
					tos[toCount++] = to + 3;
				}
				if ((board[to + 7] | board[to + 6]) == EMPTY
						&& (board[to + 8] & PIECE_AND_MOVED_MASK) == ROOK) {
					tos[toCount++] = to + 7;
				}
			}
			break;
		}
		
		case KNIGHT: {

			/* Notice how we don't check squareCapturesCastlingKing() because we will stop tracing at first / last rank anyhow. */

			var d;
			for (d = 0; d < 8; ++d) {
				to = from + KNIGHT_MOVES[d];
				if ((board[to] & color) == 0) {
					tos[toCount++] = to;
				}
			}
			break;
		}
		
		default: if (DEBUG) assert(0);
	}
	
	if (DEBUG) assert(toCount <= MAX_TARGET_SQUARES);
	return toCount;
}

function canCaptureKing(color) {
	var tos = [ ];
	var from = nextPiece[color];

	if (DEBUG) assert(isValidColor(color));

	while (from != color) {
		var toCount = listMoves(color, from, tos);
		var i;
		for (i = 0; i < toCount; ++i) {
			if (squareCapturesKing(tos[i])) {
				return true;
			}
		}
		from = nextPiece[from];
	}
	return false;
}

function findBestMove(lowestScore, alpha, beta, depth, score, movesCount, moves) {
	var bestScore = lowestScore;
	var bestMove = 0;
	var i;
	for (i = 0; i < movesCount && alpha < beta; ++i) {
		var move = moves[i];
		var from = moveFrom(move);
		var to = moveTo(move);
		var oldPiece = board[from];
		var captured = board[to];
		var oldXCapture = xCapture;
		var moveScore = doMove(from, to, oldPiece, captured, oldXCapture);
		
		var s = score + moveScore;
		if (depth > 0) {
			s = -(search(-beta, -alpha, depth - 1, -s, depth < QUIESCENCE_DEPTH) >> SCORE_SHIFT);
		}
		if (bestScore < s) {
			bestScore = s;
			bestMove = move;
			if (alpha < bestScore) {
				alpha = bestScore;
			}
		}
		
		undoMove(from, to, oldPiece, captured, oldXCapture);
	}
	return (bestScore << SCORE_SHIFT) | bestMove;
}

function searchCaptures(alpha, beta, depth, score, firstMove) {
	var capturesCount, from, moves = [ ], tos = [ ];

	if (DEBUG) assert(0 <= depth);
	if (DEBUG) assert(firstMove == 0 || isValidMove(firstMove));
		
	if (alpha < score) {
		alpha = score;
	}
	
	if (alpha >= beta) {
		return (score << SCORE_SHIFT);
	}

	capturesCount = 0;
	from = nextPiece[turnColor];
	while (from != turnColor) {
		var toCount = listMoves(turnColor, from, tos);
		var i;
		for (i = 0; i < toCount; ++i) {
			var to = tos[i];
			var move = from | (to << TO_SHIFT);

			if (squareCapturesKing(to)) {
				return ((CAPTURE_KING_MIN_SCORE + depth) << SCORE_SHIFT) | move;
			}
			
			if (board[to] > EMPTY || xCapture == to) {
				if (DEBUG) assert(capturesCount < MAX_MOVES);
				if (move == firstMove) {
					moves[capturesCount++] = moves[0];
					moves[0] = move;
				} else {
					moves[capturesCount++] = move;
				}
			}
		}
		from = nextPiece[from];
	}
	
	return findBestMove(score, alpha, beta, depth, score, capturesCount, moves);
}

function searchAll(alpha, beta, depth, score, firstMove) {
	var moves = [ ], tos = [ ], movesCount, capturesCount, from;

	if (DEBUG) assert(0 <= depth);
	if (DEBUG) assert(firstMove == 0 || isValidMove(firstMove));

	if (alpha >= beta) {
	
		/* Return dummy minimum value if alpha beta window has closed. */
		
		return (MIN_SCORE - 1) << SCORE_SHIFT;
	}

	/*
		Moves that capture will be placed before others in the array, and "firstMove" will be moved to the first
		element. This improves alpha beta pruning without sacrificing too much time on sorting.
	*/

	movesCount = 0;
	capturesCount = 0;
	from = nextPiece[turnColor];
	while (from != turnColor) {
		var toCount = listMoves(turnColor, from, tos);
		var i;
		for (i = 0; i < toCount; ++i) {
			var to = tos[i];
			var move = from | (to << TO_SHIFT);

			if (squareCapturesKing(to)) {
				
				/*
					We add depth to the score to make sure we reward early check-mates (higher depth = closer in time).
					This is very important due to the "horizon" effect.
				*/
				
				return ((CAPTURE_KING_MIN_SCORE + depth) << SCORE_SHIFT) | move;
			}
			
			if (DEBUG) assert(movesCount < MAX_MOVES);
			if (move == firstMove) {
				moves[movesCount++] = moves[capturesCount];
				if (DEBUG) assert(capturesCount < MAX_MOVES);
				moves[capturesCount++] = moves[0];
				moves[0] = move;
			} else if (board[to] > EMPTY || xCapture == to) {
				moves[movesCount++] = moves[capturesCount];
				if (DEBUG) assert(capturesCount < MAX_MOVES);
				moves[capturesCount++] = move;
			} else {
				moves[movesCount++] = move;
			}
		}
		from = nextPiece[from];
	}
	
	return findBestMove((MIN_SCORE - 1), alpha, beta, depth, score, movesCount, moves);
}

function search(alpha, beta, depth, score, capturesOnly) {
	var h, hashIndex, entry, firstMove, result, best, bestMove;

	if (DEBUG) assert(0 <= depth);
	if (DEBUG) assert(checkInvariant());

	if (beta > CAPTURE_KING_MIN_SCORE + depth) {
		
		/*
			Adjust beta if necessary to force search to end early on all checkmates (since a checkmate score changes
			depending on depth).
		*/
		
		beta = CAPTURE_KING_MIN_SCORE + depth;
	}
	
	/*
		Locate hash entry for this position using the low bits of the key and if the high bits match, begin the search
		with the previously registered best move for this position. This will speed up the process considerably due to
		alpha beta pruning.
	*/

	h = (boardHash + xCaptureKeys[xCapture] + colorKeys[turnColor]) & HASH_MASK;
	hashIndex = (h & (HASH_TABLE_SIZE - 1));
	h = (h & ~MOVE_MASK);
	entry = hashTable[hashIndex];
	firstMove = 0;
	if ((entry & ~MOVE_MASK) == h) {
		firstMove = entry & MOVE_MASK;
	}
	
	if (capturesOnly) {
		best = searchCaptures(alpha, beta, depth, score, firstMove);
		result = best;
		
		/* We can't tell if we have a checkmate just be looking at captures. Doesn't matter. We'll see them soon. */
		
	} else {
		var s;

		best = searchAll(alpha, beta, depth, score, firstMove);
		result = best;
		
		s = result >> SCORE_SHIFT;
		if (s == CAPTURE_KING_MIN_SCORE + depth) {
			
			/* Direct hit, can't go on with this. */
			
			result = (result & SCORE_MASK) | IN_CHECK;

		} else if (s == -(CAPTURE_KING_MIN_SCORE + depth - 1)) {
			
			/*
				Hit on next depth = checkmate or stalemate. To determine which, we need to make a null move and play the
				opponent to see if he can take the king. No winner with stalemate so in this case we "zero" the score.
			*/
			
			if (canCaptureKing(switchColor(turnColor))) {
				result = (result & SCORE_MASK) | CHECKMATE;
			} else {
				result = (score << SCORE_SHIFT) | STALEMATE;
			}
		}
	}

	bestMove = (best & MOVE_MASK);
	if (bestMove != 0) {
		if (DEBUG) assert(isValidMove(bestMove));
		hashTable[hashIndex] = h | bestMove;
	}
	
	++evalCounter;
	if (evalCounter < 0) {
		--evalCounter; /* Prevent wrapping with extreme high evaluation counts. */
	}
	
	return result;
}

/*
	Can return: VALID_MOVE, CHECKMATE, STALEMATE, IN_CHECK or INVALID_MOVE.
*/
function executeMove(move) {
	var tos = [ ], from;

	if (DEBUG) assert(isValidMove(move));
	
	from = nextPiece[turnColor];
	while (from != turnColor) {
		var toCount, i;
		if (DEBUG) assert(board[from] > EMPTY && (board[from] & COLOR_MASK) == turnColor);
		toCount = listMoves(turnColor, from, tos);
		if (DEBUG) assert(toCount <= MAX_TARGET_SQUARES);
		for (i = 0; i < toCount; ++i) {
			var to = tos[i];
			if (move == (from | (to << TO_SHIFT))) {
				var oldPiece = board[from];
				var captured = board[to];
				var oldXCapture = xCapture;
				doMove(from, to, oldPiece, captured, oldXCapture);	
				
				switch (search(MIN_SCORE, MAX_SCORE, 1, 0, false) & MOVE_MASK) {
					default: return VALID_MOVE;
					case CHECKMATE: return CHECKMATE;
					case STALEMATE: return STALEMATE;
					case IN_CHECK: {
						undoMove(from, to, oldPiece, captured, oldXCapture);
						return IN_CHECK;
					}
				}
			}
		}
		from = nextPiece[from];
	}
		
	return INVALID_MOVE;
}

/*
	Can return: 16-bit move code or CHECKMATE or STALEMATE.
*/
function getComputerMove() {
	var d;
	var printedThinking = false;
	var m = 0;
	evalCounter = 0;
	for (d = MIN_DEPTH; d <= MAX_DEPTH && evalCounter < minEvals; ++d) {
		if (evalCounter > 1000000) {
			if (!printedThinking) {
				console.log("Thinking...", stdout);
				printedThinking = true;
			}
		}
		m = search(MIN_SCORE, MAX_SCORE, d, 0, false);
	}
	if (DEBUG) assert((m & MOVE_MASK) == CHECKMATE || (m & MOVE_MASK) == STALEMATE || isValidMove(m & MOVE_MASK));
	return m & MOVE_MASK;
}

function printBoard(from, to) {
	var y;
	var lastI = -1;
	var s = "    A B C D E F G H\n";
	s += "  +-----------------+\n";
	for (y = 0; y < 8; ++y) {
		var c;
		var x;
		s += (8 - y) + " |";
		for (x = 0; x < 8; ++x) {
			var i = (9 - y) * STRIDE + (x + 1);
			c = ' ';
			if (i == from || i == to) c = '(';
			if (lastI == from || lastI == to) c = (c == '(' ? ' ' : ')');
			s += c;
			c = PIECE_CHARS[board[i] & (PIECE_MASK | BLACK)];
			if (c == ' ' && ((x ^ y) & 1) == 1) c = '.';
			s += c;
			lastI = i;
		}
		c = ' ';
		if (lastI == from || lastI == to) c = ')';
		s += c;
		s += "| " + ('8' - y) + "\n";
		lastI = -1;
	}
	s += "  +-----------------+\n";
	s += "    A B C D E F G H\n\n";
	print(s);
}

function registerMove(move, piece, captured, xCapture) {
	var i;
	if (historyCount >= HISTORY_SIZE) {
		var j;
		--historyCount;
		for (j = 0; j < historyCount * 4; ++j) {
			chessHistory[j] = chessHistory[j + 4];
		}
	}
	i = historyCount * 4;
	chessHistory[i + 0] = move;
	chessHistory[i + 1] = piece;
	chessHistory[i + 2] = captured;
	chessHistory[i + 3] = xCapture;
	++historyCount;
}

function takeBackMove() {
	if (historyCount > 0) {
		var i, move, from, to;
		--historyCount;
		i = historyCount * 4;
		move = chessHistory[i + 0];
		from = moveFrom(move);
		to = moveTo(move);
		undoMove(from, to, chessHistory[i + 1], chessHistory[i + 2], chessHistory[i + 3]);
		return move;
	} else {
		return 0;
	}
}

function setLevel(level) {
	var i;
	minEvals = 100;
	for (i = 0; i < level; ++i) minEvals *= 5;
}

initGlobals();
restart();
setLevel(1);

while (true) {
	var move;
	if ((move = getComputerMove()) != CHECKMATE && move != STALEMATE) { executeMove(move); printBoard(0, 0) }
	else break;
}
