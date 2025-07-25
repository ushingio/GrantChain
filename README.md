# GrantChain

A decentralized research grant application and funding management system for academic research on Stacks blockchain.

## Features

- Research grant application with comprehensive proposal documentation
- Applicant funding management and validation
- Funding agency classification system
- Grant type specification and tracking
- Application status management and award workflow

## Smart Contract Functions

### Public Functions
- `apply-for-grant` - Apply for research grant with proposal
- `award-grant` - Award grant funding (applicant only)

### Read-Only Functions
- `get-grant` - Get research grant details
- `get-applicant` - Get grant applicant information
- `get-total-grants` - Get total grant applications
- `get-application-status` - Get grant application status

## Funding Agencies
- NSF, NIH, DOE, NASA, DARPA, Private

## Grant Types
- Basic, Applied, SBIR, Fellowship, Equipment

## Usage

Deploy the contract to create a research grant system where applicants can submit proposals and track their progress through the funding award process.

## License

MIT