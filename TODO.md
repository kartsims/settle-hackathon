#########################
# INTEGRATION TO SETTLE #
#########################

- after loading the page (work and helper modes ONLY)
  - update tx history
  - display loading indicator fixed to the top of the page "updating transactions history... 2/15"
- after loading the page
  - header banner : "listening to ERC20 transactions..."
  - spinner
  - web3 event listener
  - display current block number
- "About"
  - This app has been developed by Simon Tarchichi for Settle.finance. 
  - Request new features or share your opinion by submitting the form below.
  - SMALL FORM BOUND TO API
    

mode helper = 225 de large, hauteur dépend de l'écran
mode alert = 120 de haut, 275-400 de large

# ACCOUNTS

Button "show all balances"
When showing balances, help text saying "balances updated at XXX"

# TRANSACTIONS

"Waiting for transactions..." + spinner + block number

# CHARTS

One chart per token : 15 days of txs
Selectbox "Select an account"

# ALERTS

Alert mode : "Waiting for transactions..." + spinner + block number
When a new tx is made : display the tx on top in a separate table, marked as "New"
