#########################
# INTEGRATION TO SETTLE #
#########################

- API
  - replacement for cors-anywhere used in `TokenTopAccounts.vue`
  - receive contact form data
- after loading the page
  - header banner : "listening to ERC20 transactions..."
  - spinner
  - web3 event listener
  - display current block number
- charts
  - do not display if no value available
    

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
