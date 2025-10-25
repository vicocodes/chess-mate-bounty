;; Chess Mate Bounty - Solve chess puzzles to earn crypto
;; A simple chess puzzle contract on Stacks blockchain

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-puzzle-not-found (err u101))
(define-constant err-already-solved (err u102))
(define-constant err-incorrect-solution (err u103))
(define-constant err-insufficient-funds (err u104))
(define-constant err-puzzle-exists (err u105))

;; Data Variables
(define-data-var puzzle-counter uint u0)

;; Data Maps
(define-map puzzles
  { puzzle-id: uint }
  {
    creator: principal,
    fen-position: (string-ascii 100),
    solution-hash: (buff 32),
    bounty: uint,
    difficulty: uint,
    solved: bool,
    solver: (optional principal)
  }
)

(define-map user-stats
  { user: principal }
  {
    puzzles-solved: uint,
    total-earned: uint
  }
)

;; Read-only functions

(define-read-only (get-puzzle (puzzle-id uint))
  (map-get? puzzles { puzzle-id: puzzle-id })
)

(define-read-only (get-user-stats (user principal))
  (default-to
    { puzzles-solved: u0, total-earned: u0 }
    (map-get? user-stats { user: user })
  )
)

(define-read-only (get-puzzle-count)
  (var-get puzzle-counter)
)

;; Public functions

(define-public (create-puzzle (fen-position (string-ascii 100)) (solution-hash (buff 32)) (difficulty uint))
  (let
    (
      (new-puzzle-id (+ (var-get puzzle-counter) u1))
      (bounty-amount (* difficulty u1000000)) ;; 1 STX per difficulty level (in microSTX)
    )
    ;; Transfer bounty from creator to contract
    (try! (stx-transfer? bounty-amount tx-sender (as-contract tx-sender)))
    
    ;; Store puzzle
    (map-set puzzles
      { puzzle-id: new-puzzle-id }
      {
        creator: tx-sender,
        fen-position: fen-position,
        solution-hash: solution-hash,
        bounty: bounty-amount,
        difficulty: difficulty,
        solved: false,
        solver: none
      }
    )
    
    ;; Increment counter
    (var-set puzzle-counter new-puzzle-id)
    
    (ok new-puzzle-id)
  )
)

(define-public (submit-solution (puzzle-id uint) (solution (string-ascii 50)))
  (let
    (
      (puzzle (unwrap! (map-get? puzzles { puzzle-id: puzzle-id }) err-puzzle-not-found))
      (solution-hash-input (sha256 (unwrap-panic (to-consensus-buff? solution))))
    )
    ;; Check if puzzle is already solved
    (asserts! (not (get solved puzzle)) err-already-solved)
    
    ;; Verify solution
    (asserts! (is-eq solution-hash-input (get solution-hash puzzle)) err-incorrect-solution)
    
    ;; Update puzzle as solved
    (map-set puzzles
      { puzzle-id: puzzle-id }
      (merge puzzle {
        solved: true,
        solver: (some tx-sender)
      })
    )
    
    ;; Update user stats
    (let
      (
        (current-stats (get-user-stats tx-sender))
      )
      (map-set user-stats
        { user: tx-sender }
        {
          puzzles-solved: (+ (get puzzles-solved current-stats) u1),
          total-earned: (+ (get total-earned current-stats) (get bounty puzzle))
        }
      )
    )
    
    ;; Transfer bounty to solver
    (try! (as-contract (stx-transfer? (get bounty puzzle) tx-sender tx-sender)))
    
    (ok true)
  )
)

(define-public (withdraw-unsolved-puzzle (puzzle-id uint))
  (let
    (
      (puzzle (unwrap! (map-get? puzzles { puzzle-id: puzzle-id }) err-puzzle-not-found))
    )
    ;; Only creator can withdraw
    (asserts! (is-eq tx-sender (get creator puzzle)) err-owner-only)
    
    ;; Puzzle must not be solved
    (asserts! (not (get solved puzzle)) err-already-solved)
    
    ;; Transfer bounty back to creator
    (try! (as-contract (stx-transfer? (get bounty puzzle) tx-sender (get creator puzzle))))
    
    ;; Mark puzzle as solved to prevent further submissions
    (map-set puzzles
      { puzzle-id: puzzle-id }
      (merge puzzle { solved: true })
    )
    
    (ok true)
  )
)