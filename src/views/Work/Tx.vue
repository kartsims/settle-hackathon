<template>
  <div>

    <pre>{{watchListTxLoading.length}} watchListTxLoading => {{ watchListTxLoading }}</pre>
    <pre>{{watchListTxNotLoaded.length}} watchListTxNotLoaded => {{ watchListTxNotLoaded }}</pre>
    <pre>{{watchList.length}} watchList => {{ watchList }}</pre>
    <pre>{{txs.length}} txs => {{ txs }}</pre>

  </div>
</template>

<script>
/*
https://ethereum.stackexchange.com/questions/28561/how-to-query-token-transfers-like-etherscan-io
*/
import { mapGetters, mapState } from 'vuex'

export default {
  created() {
    // this.watchList.forEach(payload => {
    //   this.$store.dispatch('getTxs', payload)
    // })
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
  },
}
</script>

<style lang="scss" scoped>
</style>
