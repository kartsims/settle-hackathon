<template>
  <div>
    <div class="empty" v-if="items.length === 0">
      No transactions available
    </div>
    <table class="txs" v-else>
      <tr
        v-for="(tx, index) in items" 
        :key="tx.hash"
        :class="{odd: index%2 === 0}"
        @click="seeTx(tx)"
      >
        <td class="date">
          {{ tx.date }}
        </td>
        <td class="out">
          <span v-if="tx.out">OUT</span>
          <span class="in" v-else>IN</span>
        </td>
        <td class="value">
          {{ tx.valueRound }}<span class="decimal">{{ tx.valueDecimal }}</span>
          <span class="ticker">
            {{ tx.token.ticker }}
          </span>
        </td>
        <td class="address">
          {{ tx.address }}
        </td>
      </tr>
    </table>

  </div>
</template>

<script>
import moment from 'moment'
import { mapGetters } from 'vuex'

export default {
  props: ['txs'],
  computed: {
    ...mapGetters(['getToken']),
    items () {
      const mapTx = tx => {
        const value = Math.abs(tx.value)
        let valueDecimal = Math.round((value - Math.floor(value)) * 1000)
        if (valueDecimal === 0) {
          valueDecimal = ''
        } else {
          valueDecimal = valueDecimal.toString()
          while (valueDecimal.length < 3) {
            valueDecimal = '0' + valueDecimal
          }
          valueDecimal = '.' + valueDecimal
        }
        return {
          date: moment.unix(tx.timestamp).format('YYYY-MM-DD HH:mm:ss'),
          address: tx.address,
          hash: tx.hash,
          value,
          valueRound: Math.floor(value),
          valueDecimal,
          out: tx.value < 0,
          token: this.getToken(tx.tokenAddress),
        }
      }
      return this.txs.map(mapTx)
    },
  },
  methods: {
    seeTx (tx) {
      window.open('https://etherscan.io/tx/' + tx.hash)
    },
  },
}
</script>

<style lang="scss" scoped>
table {
  font-size: 12px;
  tr {
    &.odd {
      background: #1a2129;
    }
    &:hover {
      background: #2c3e50;
      color: #fff;
      cursor: pointer;
    }
  }
  td {
    padding: 2px 4px;
  }
  td.date {
    font-size: 10px;
  }
  td.value {
    font-family: 'Courier New', Courier, monospace;
    text-align: right;
    .decimal {
      display: inline-block;
      width: 36px;
      opacity: .5;
      text-align: left;
    }
    .ticker {
      display: inline-block;
      width: 30px;
      text-align: left;
    }
  }
  td.out {
    text-align: center;
    span {
      font-size: .7em;
      color: #fff;
      padding: .1em .6em;
      border-radius: .2em;
      display: inline-block;
      background: rgb(139, 13, 13);
      &.in {
        background: rgb(23, 94, 23);
      }
    }
  }
  td.address {
    font-family: 'Courier New', Courier, monospace;
    font-size: .8em;
  }
}
.empty {
  opacity: .5;
  padding: 30px 0;
  font-style: italic;
}
</style>
