# Chess Mate Bounty 🎯♟️

A decentralized chess puzzle platform built on the Stacks blockchain where players solve tactical chess positions to earn STX cryptocurrency.

## Overview

Chess Mate Bounty is a smart contract that allows chess enthusiasts to:
- Create chess puzzles with crypto bounties
- Solve puzzles to earn STX rewards
- Track their solving statistics and earnings
- Compete on a skill-based platform

## Features

### 🎲 Puzzle Creation
- Create chess puzzles using standard FEN notation
- Set difficulty levels (1-5 or higher)
- Automatic bounty calculation: 1 STX per difficulty level
- Secure solution verification using SHA256 hashing

### 💰 Earn Crypto
- Solve puzzles to earn STX immediately
- Fair and transparent reward distribution
- No intermediaries or delays

### 📊 Player Statistics
- Track total puzzles solved
- Monitor total earnings
- Build your reputation as a chess tactician

### 🔒 Security Features
- Solution hashing prevents cheating
- Creator can withdraw unsolved puzzle bounties
- One solution per puzzle
- Only verified solutions receive rewards

## How It Works

### For Puzzle Creators

1. **Prepare Your Puzzle**
   - Choose a chess position (FEN notation)
   - Determine the correct solution
   - Hash your solution using SHA256

2. **Create the Puzzle**
   ```clarity
   (contract-call? .chess-mate-bounty create-puzzle
     "r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4"
     0x5a7d6c8e9f... ;; SHA256 hash of "Bxf7+"
     u3) ;; Difficulty 3 = 3 STX bounty
   ```

3. **Wait for Solvers**
   - Players attempt to solve your puzzle
   - First correct solution wins the bounty

4. **Withdraw if Needed**
   - Retrieve your bounty if the puzzle remains unsolved
   ```clarity
   (contract-call? .chess-mate-bounty withdraw-unsolved-puzzle u1)
   ```

### For Puzzle Solvers

1. **Browse Available Puzzles**
   ```clarity
   (contract-call? .chess-mate-bounty get-puzzle u1)
   ```

2. **Submit Your Solution**
   ```clarity
   (contract-call? .chess-mate-bounty submit-solution u1 "Bxf7+")
   ```

3. **Earn Rewards**
   - If correct, STX is transferred to your wallet immediately
   - Your stats are updated automatically

4. **Check Your Stats**
   ```clarity
   (contract-call? .chess-mate-bounty get-user-stats 'ST1PQHQKV...)
   ```

## Solution Format

Solutions should be submitted in standard algebraic notation (SAN):
- `e4` - Pawn move
- `Nf3` - Knight move
- `Bxf7+` - Bishop captures with check
- `O-O` - Kingside castling
- `Qd8#` - Queen checkmate

For multi-move puzzles, separate moves with spaces: `"Bxf7+ Kxf7 Qd5+"`

## Generating Solution Hashes

To create a puzzle, you need to hash your solution:

### Using Command Line (Linux/Mac)
```bash
echo -n "Bxf7+" | sha256sum
```

### Using Python
```python
import hashlib
solution = "Bxf7+"
hash_object = hashlib.sha256(solution.encode())
print(hash_object.hexdigest())
```

### Using JavaScript
```javascript
const crypto = require('crypto');
const solution = "Bxf7+";
const hash = crypto.createHash('sha256').update(solution).digest('hex');
console.log(hash);
```

## Contract Functions

### Read-Only Functions

- **`get-puzzle (puzzle-id uint)`**
  - Returns puzzle details including FEN, bounty, difficulty, and solved status

- **`get-user-stats (user principal)`**
  - Returns user's puzzles solved and total earnings

- **`get-puzzle-count`**
  - Returns the total number of puzzles created

### Public Functions

- **`create-puzzle (fen-position, solution-hash, difficulty)`**
  - Creates a new puzzle with automatic bounty calculation
  - Requires STX transfer from creator

- **`submit-solution (puzzle-id, solution)`**
  - Submit a solution attempt for a puzzle
  - Transfers bounty if solution is correct

- **`withdraw-unsolved-puzzle (puzzle-id)`**
  - Allows creator to withdraw bounty from unsolved puzzle

## Error Codes

| Code | Error | Description |
|------|-------|-------------|
| u100 | err-owner-only | Only the owner can perform this action |
| u101 | err-puzzle-not-found | Puzzle ID does not exist |
| u102 | err-already-solved | Puzzle has already been solved |
| u103 | err-incorrect-solution | Submitted solution is incorrect |
| u104 | err-insufficient-funds | Not enough STX for transaction |
| u105 | err-puzzle-exists | Puzzle already exists |

## Deployment

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet (Hiro Wallet, Xverse, etc.)
- STX for gas fees and bounties

### Deploy to Testnet

1. **Initialize Clarinet project**
   ```bash
   clarinet new chess-mate-bounty
   cd chess-mate-bounty
   ```

2. **Add the contract**
   - Copy the contract code to `contracts/chess-mate-bounty.clar`

3. **Test the contract**
   ```bash
   clarinet test
   ```

4. **Deploy to testnet**
   ```bash
   clarinet deploy --testnet
   ```

### Deploy to Mainnet

```bash
clarinet deploy --mainnet
```

## Example Puzzles

### Beginner (Difficulty 1)
**FEN:** `r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4`  
**Solution:** `Bxf7+` (Scholar's Mate setup)

### Intermediate (Difficulty 3)
**FEN:** `r1bq1rk1/ppp2ppp/2np1n2/2b1p3/2B1P3/2NP1N2/PPP2PPP/R1BQK2R w KQ - 0 8`  
**Solution:** `Bxf7+ Rxf7 Nxe5` (Remove the Defender)

### Advanced (Difficulty 5)
**FEN:** `r2qk2r/ppp2ppp/2n1bn2/2bpp3/4P3/2NP1N2/PPP2PPP/R1BQKB1R w KQkq - 0 7`  
**Solution:** `Nxe5 Nxe5 d4` (Tactical breakthrough)

## Best Practices

### For Creators
- Test your solution before creating the puzzle
- Use standard chess notation for consistency
- Set appropriate difficulty levels
- Provide clear tactical themes (pins, forks, skewers, etc.)

### For Solvers
- Analyze the position carefully
- Look for tactical motifs
- Use proper chess notation
- Double-check your solution before submitting

## Security Considerations

- Solutions are hashed, so they remain secret until solved
- Only one solution per puzzle (first correct solver wins)
- Creators can retrieve funds from unsolved puzzles
- All transactions are transparent on the blockchain

## Contributing

This is an open-source project. Contributions are welcome!

Ideas for enhancement:
- Multi-move puzzle support
- Puzzle categories (opening traps, endgames, tactics)
- Rating system for puzzles
- Leaderboard functionality
- Puzzle comments and discussions

## Support

For issues, questions, or suggestions, please open an issue on the project repository.

---

**Built with ♟️ on Stacks Blockchain**

*Play chess. Earn crypto. Sharpen your tactics.*