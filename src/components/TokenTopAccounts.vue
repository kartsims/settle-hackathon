<template>
  <div>

    <h3>Top accounts</h3>

    <div class="items">
      <div 
        v-for="account in accounts"
        :key="account.address"
        @click="$emit('change', account.address)"
        class="item"
      >
        <span class="address">
          {{ account.address }}
        </span>
        <span class="balance">
          {{ token.ticker }} {{ account.balanceString }}
        </span>
      </div>
    </div>

    <div class="loading" v-if="loading">
      Loading...
    </div>
    <div class="more" v-else>
      <a @click="loadItems">Load more</a>
    </div>

  </div>
</template>

<script>
import request from 'async-request'
import cheerio from 'cheerio'
import numeral from 'numeral'

export default {
  props: ['token'],
  data () {
    return {
      loading: false,
      accounts: [],
      currentPage: 1,
    }
  },
  created () {
    this.loadItems()
  },
  methods: {
    async loadItems () {
      try {
        this.loading = true
        const { body } = await request('https://cors-anywhere.herokuapp.com/https://etherscan.io/token/generic-tokenholders2?a='+ this.token.address + '&s=1.40245398245133E%2b26&p=' + this.currentPage)

        const $ = await cheerio.load(body)

        $('#maintable').find('tr').each((i,el) => {
          const account = {
            address: null,
            balance: null,
            balanceString: null,
          }
          $(el).children().each((i,el) => {
            if (i === 1) {
              account.address = $(el).text()
            } else if (i === 2) {
              account.balance = Math.round(+$(el).text())
              account.balanceString = numeral(account.balance).format('0,0')
            }
          })
          if (account.balance) {
            this.accounts.push(account)
          }
        })
        this.currentPage++
      } catch(e) {
        console.log(e)
      }
      this.loading = false
    },
  },
}
</script>

<style lang="scss" scoped>
h3 {
  margin-top: 40px;
  opacity: .5;
}
.items {
  margin: 20px auto 0;
  width: 520px;
}
input {
  margin-bottom: 20px;
  width: 100%;
  text-align: center;
  font-size: 16px;
  padding: 10px 0;
}
.item {
  padding: 5px;
  cursor: pointer;
  display: flex;
  width: 100%;
  .address {
    font-family: 'Courier New', Courier, monospace;
    font-size: 14px;
  }
  .balance {
    opacity: .5;
    padding-left: 20px;
  }
  &:hover {
    color: #fff;
    background: #2c3e50;
  }
}
.empty {
  padding: 20px 0;
  font-style: italic;
}
.loading, .more {
  margin-top: 10px;
  padding: 20px 0;
  font-size: 16px;
}
.loading {
  opacity: .5;
}
.more {
  color: #f6a622;
  text-decoration: underline;
  cursor: pointer;
}
</style>
