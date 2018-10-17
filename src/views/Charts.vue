<template>
  <div>

    <div class="filters">
      <select v-model="tokenAddress">
        <option :value="null">All tokens</option>
        <option 
          v-for="token in tokens" 
          :key="token.ticker"
          :value="token.address"
        >
          {{ token.name }}
        </option>
      </select>
    </div>

    <h3 v-if="token">
      {{ token.name }} ({{ token.ticker }})
    </h3>

    <div class="total">
      Total over the last {{ configTxHistoryDays }} days :
      {{ totalIn }} / {{ totalOut }}
    </div>

    <Chart
      :height="200"
      :labels="labels"
      :inValues="inValues"
      :outValues="outValues"
    />

  </div>
</template>

<script>
import moment from 'moment'
import { mapGetters, mapState } from 'vuex'
import config from '../../config.json'
import displayAmount from '@/utils/displayAmount'

import Chart from '@/components/Chart.vue'

export default {
  components: {
    Chart,
  },
  data () {
    return {
      configTxHistoryDays: config.txHistoryDays,
      tokenAddress: null,
    }
  },
  computed: {
    ...mapGetters(['getToken']),
    ...mapState(['txs']),
    tokens () {
      let tokens = []
      this.txs.forEach(tx => {
        if (tokens.indexOf(tx.tokenAddress) === -1) {
          tokens.push(tx.tokenAddress)
        }
      })
      return tokens.map(tokenAddress => this.getToken(tokenAddress))
    },
    values () {
      const addNumber = 1
      const addType = 'day'
      const dateFormat = 'YYYY-MM-DD'

      let values = {}
      const value = moment().subtract(config.txHistoryDays, 'days')
      const today = moment()
      while (value.isSameOrBefore(today)) {
        let date = value.format(dateFormat)
        values[date] = {}
        values[date].out = 0
        values[date].in = 0
        value.add(1, 'hour')
      }
      this.txs.forEach(tx => {
        if (this.tokenAddress && tx.tokenAddress !== this.tokenAddress) {
          return
        }
        const date = moment.unix(tx.timestamp).format(dateFormat)
        if (!values[date]) {
          return
        }
        if (tx.value > 0) {
          values[date].in += tx.value
        } else {
          values[date].out -= tx.value
        }
      })
      return values
    },
    labels () {
      return Object.keys(this.values)
    },
    inValues () {
      return Object.keys(this.values).map(date => this.values[date].in)
    },
    outValues () {
      return Object.keys(this.values).map(date => -this.values[date].out)
    },
    token () {
      if (!this.tokenAddress) {
        return null
      }
      return this.getToken(this.tokenAddress)
    },
    totalIn () {
      return displayAmount(this.inValues.reduce((total, value) => total + value, 0))
    },
    totalOut () {
      return displayAmount(this.outValues.reduce((total, value) => total + value, 0))
    },
  }
}
</script>

<style lang="scss" scoped>
.filters {
  padding-bottom: 20px;
  text-align: right;
}
h3 {
  padding: 0 0 30px;
}
.total {
  font-size: 12px;
  position: relative;
  top: -20px;
  opacity: .5;
}
</style>
