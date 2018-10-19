<template>
  <div class="tx-updater" v-if="loading">
    Updating transactions history
    <span v-if="watchList.length">
      {{ nbDone.toString() }} / {{ watchList.length }}
    </span>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import * as async from '@/utils/async'

export default {
  data () {
    return {
      loading: true,
      nbDone: 0,
    }
  },
  async created () {
    await async.forEach(this.watchList, async (item) => {
      await this.$store.dispatch('getTxs', item)
      this.nbDone++
    })
    this.loading = false
  },
  computed: {
    ...mapState(['watchList']),
  },
}
</script>

<style lang="scss" scoped>
.tx-updater {
  padding: 10px;
  margin-bottom: 10px;
  background: #2c3e50;
  font-size: 12px;
  span {
    margin-left: 15px;
  }
}
</style>
