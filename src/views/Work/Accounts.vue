<template>
  <div>

    <div class="header">

      <span v-if="watchList.length > 1" class="count">
        Group by 
        <label>
          <input type="radio" v-model="groupBy" value="token"/>
          Token
        </label>
        <label>
          <input type="radio" v-model="groupBy" value="address"/>
          Account
        </label>
      </span>
      
      <span v-else-if="watchList.length === 0" class="count empty">
        No account watched yet
        <br/>
        <br/>
        <router-link to="/work/add" class="add">Add an account</router-link>
      </span>

    </div>

    <table :class="'grouped-by-' + groupBy">
      <template v-for="(itemList, group) in items">
        <tr :key="groupBy + 'grouptitle' + group">
          <td colspan="10" class="title">
            {{ itemGroupName(group) }}
          </td>
        </tr>
        <tr 
          v-for="item in itemList" 
          :key="groupBy + 'list' + item"
        >
          <td class="name">
            {{ itemName(item) }}
          </td>
          <td class="icon">
            <a :href="itemLink(group, item)" target="_blank">
              <i class="icon-external"/>
            </a>
          </td>
          <td class="icon">
            <a href="#" @click.prevent="removeItem(group, item)">
              <i class="icon-remove"/>
            </a>
          </td>
        </tr>
      </template>
    </table>

  </div>
</template>

<script>
import { mapGetters, mapState } from 'vuex'

export default {
  data () {
    return {
      groupBy: 'token',
      accounts: [],
    }
  },
  computed: {
    ...mapGetters(['getToken']),
    ...mapState(['watchList']),
    items () {
      let items = {}
      if (this.groupBy === 'token') {
        this.watchList.forEach(i => {
          if (items[i.tokenAddress] === undefined) {
            items[i.tokenAddress] = []
          }
          items[i.tokenAddress].push(i.address)
        })
      }
      if (this.groupBy === 'address') {
        this.watchList.forEach(i => {
          if (items[i.address] === undefined) {
            items[i.address] = []
          }
          items[i.address].push(i.tokenAddress)
        })
      }
      return items
    },
  },
  methods: {
    itemGroupName(value) {
      if (this.groupBy === 'token') {
        const token = this.getToken(value)
        return token ? `${token.name} (${token.ticker})` : null
      }
      return value
    },
    itemName(value) {
      if (this.groupBy === 'token') {
        return value
      }
      const token = this.getToken(value)
      return token ? `${token.name} (${token.ticker})` : null
    },
    itemLink(group, item) {
      const address = this.groupBy === 'token' ? item : group
      const tokenAddress = this.groupBy === 'token' ? group : item
      return `https://etherscan.io/token/${tokenAddress}?a=${address}`
    },
    removeItem(group, item) {
      if (!confirm('Remove this account from your watchlist ?')) {
        return
      }
      const address = this.groupBy === 'token' ? item : group
      const tokenAddress = this.groupBy === 'token' ? group : item
      this.$store.commit('WATCHLIST_REMOVE', {
        address,
        tokenAddress,
      })
      this.$store.commit('TX_ACCOUNT_REMOVE', {
        address,
        tokenAddress,
      })
    },
  },
}
</script>

<style lang="scss" scoped>
.count {
  display: block;
  height: 32px;
  line-height: 32px;
  font-size: 13px;
  margin: 0 5px 20px;
  &.empty {
    text-align: center;
    margin: 40px 0;
  }
}
a.add {
  display: inline-block;
  text-decoration: none;
  border-radius: 2px;
  color: inherit;
  border: 1px solid #ffffffc7;
  padding: 4px 15px;
  &:hover {
    color: #f6a622;
    border-color: #f6a622;
  }
}
table {
  td {
    padding: 5px;
  }
  td.icon {
    padding-left: 20px;
    padding-right: 0px;
    width: 10px;
  }
  &.grouped-by-address {
    td.title {
      padding: 25px 5px 10px;
      color: #fff;
      font-size: 16px;
      font-family: 'Courier New', Courier, monospace;
      font-weight: bold;
    }
    td.name {
      padding-right: 20px;
    }
  }
  &.grouped-by-token {
    td.title {
      padding: 15px 5px 10px;
      color: #fff;
      font-size: 20px;
      font-weight: bold;
    }
    td.name {
      font-family: 'Courier New', Courier, monospace;
      padding-right: 20px;
    }
  }
}
</style>
