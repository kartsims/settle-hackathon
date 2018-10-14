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

    <div 
      v-for="(itemList, group) in items" 
      :key="groupBy + 'group' + group"
    >
      <h3>{{ itemGroupName(group) }}</h3>
      <ul>
        <li v-for="item in itemList" :key="groupBy + 'list' + item">
          <a :href="itemLink(group, item)" target="_blank">
            {{ itemName(item) }}
          </a>
        </li>
      </ul>

    </div>

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
    }
  },
}
</script>

<style lang="scss" scoped>
.count {
  display: block;
  height: 32px;
  line-height: 32px;
  font-size: 13px;
  margin: 0 0 20px;
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
ul {
  margin: 0;
  padding: 10px 0 30px 25px;
  a {
    color: inherit;
  }
}
</style>
