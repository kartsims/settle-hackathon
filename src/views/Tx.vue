<template>
  <div>

    <TxLoading :items="watchListTxLoading"/>

    <TxNotLoaded :items="watchListTxNotLoaded"/>
    
    <div class="filters">

      <select v-model="filterByAccount">
        <option :value="null">All accounts</option>
        <option
          v-for="account in accounts" 
          :value="account"
          :key="account"
        >
          {{ account }}
        </option>
      </select>
      <label @click="groupByToken = !groupByToken">
        <i :class="groupByToken ? 'icon-check-on' : 'icon-check-off'"/>
        group by token
      </label>
    </div>

    <TxList v-if="!groupByToken" :txs="filteredTxs"/>
    <div v-else>
      <div 
        v-for="token in tokenGroups" 
        :key="'token' + token.ticker"
        class="token-group"
      >
        <h3>{{ token.name }} ({{ token.ticker }})</h3>
        <TxList :txs="token.txs"/>
      </div>
      <TxList v-if="tokenGroups.length === 0" :txs="[]"/>
    </div>

    <div class="count">
      Showing last {{ txHistoryDays }} days only
    </div>

  </div>
</template>

<script>
/*
https://ethereum.stackexchange.com/questions/28561/how-to-query-token-transfers-like-etherscan-io
*/
import { mapGetters, mapState } from 'vuex'
import config from '../../config.json'

import TxList from '@/components/TxList.vue'
import TxLoading from '@/components/TxLoading.vue'
import TxNotLoaded from '@/components/TxNotLoaded.vue'

export default {
  components: {
    TxList,
    TxLoading,
    TxNotLoaded,
  },
  data () {
    return {
      txHistoryDays: config.txHistoryDays,
      groupByToken: false,
      filterByAccount: null,
    }
  },
  computed: {
    ...mapGetters(['getToken']),
    ...mapState(['watchList', 'txs']),
    watchListTxLoading () {
      return this.watchList.filter(i => i.txLoaded === null)
    },
    watchListTxNotLoaded () {
      return this.watchList.filter(i => i.txLoaded === false)
    },
    watchListTxLoaded () {
      return this.watchList.filter(i => i.txLoaded === true)
    },
    filteredTxs () {
      if (this.filterByAccount) {
        return this.txs.filter(tx => tx.address === this.filterByAccount)
      }
      return this.txs
    },
    accounts () {
      const accounts = []
      this.watchList.forEach(item => {
        if (accounts.indexOf(item.address) === -1) {
          accounts.push(item.address)
        }
      })
      return accounts.sort()
    },
    tokenGroups () {
      let tokenGroups = {}
      this.filteredTxs.forEach(tx => {
        if (tokenGroups[tx.tokenAddress] === undefined)(
          tokenGroups[tx.tokenAddress] = []
        ) 
        tokenGroups[tx.tokenAddress].push(tx)
      })
      return Object.keys(tokenGroups).map(tokenAddress => {
        const token = this.getToken(tokenAddress)
        return {
          ...token,
          txs: tokenGroups[tokenAddress],
        }
      })
    },
  },
}
</script>

<style lang="scss" scoped>
div.count {
  font-size: 12px;
  padding: 10px 0;
  opacity: .5;
}
.filters {
  font-size: 14px;
  padding: 15px 0;
  select {
    margin-right: 10px;
  }
  label {
    font-size: 12px;
    cursor: pointer;
  }
}
.token-group {
  padding: 10px 0 20px;
  h3 {
    padding-bottom: 10px;
  }
}
</style>
