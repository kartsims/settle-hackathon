<template>
  <div>

    <TxUpdater/>

    <div class="menu">

      <h1 @click="$router.push('/work/about')">ERC20 Whale Watcher</h1>

      <div class="tabs">

        <router-link to="/work/add" class="button">
          +
        </router-link>
        <router-link to="/work" class="tab">
          Transactions
        </router-link>
        <router-link to="/work/accounts" class="tab">
          Watchlist
        </router-link>
      </div>

    </div>

    <div class="content">
      <router-view/>
    </div>
    
  </div>
</template>

<script>
import TxUpdater from '@/components/TxUpdater.vue'

export default {
  components: {
    TxUpdater,
  },
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>
.menu {
  display: flex;
  flex-direction: row-reverse;
  justify-content: space-between;
  margin: 0 10px;
}

h1 {
  margin-top: 15px;
  cursor: pointer;
  &:hover {
    color: #ffffffc2;
  }
}

.tabs {
  margin: 15px 0;
  height: 50px;
  position: relative;
  .tab {
    display: inline-block;
    height: 36px;
    line-height: 36px;
    padding: 0 15px;
    margin: 0 20px 0 0;
    cursor: pointer;
    text-decoration: none;
    font-size: 13px;
    color: #ffffffc7;
    &.router-link-exact-active {
      border-bottom: 2px solid #f6a622;
    }
  }
  .button {
    display: inline-block;
    width: 24px;
    height: 24px;
    line-height: 24px;
    text-align: center;
    margin: 0 20px 0 0;
    cursor: pointer;
    text-decoration: none;
    font-size: 18px;
    outline: none;
    color: #2c3e50;
    border-radius: 2px;
    background: #ffffffc7;
    text-decoration: none;
    &.router-link-exact-active {
      background: #f6a622;
    }
  }
}
.content {
  padding: 0 10px 20px;
}
</style>
