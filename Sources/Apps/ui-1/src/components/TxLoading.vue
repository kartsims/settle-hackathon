<template>
  <div class="inner" v-if="items.length > 0">
    <i class="icon-spinner animate-spin"/>
    {{ items.length }} account<span v-text="items.length > 1 ? 's\'' : '\'s'"/> transactions are loading
    <a v-if="!locktimeLeft" href="#" @click.prevent="retry">retry</a>
    <a v-else class="locked" href="#">wait {{ locktimeLeft }} seconds before trying again...</a>
  </div>
</template>

<script>
export default {
  props: ['items'],
  data () {
    return {
      locktimeLeft: 0,
    }
  },
  methods: {
    retry () {
      if (this.locktimeLeft) {
        return
      }
      
      this.items.forEach(item => {
        this.$store.dispatch('getTxs', {
          address: item.address,
          tokenAddress: item.tokenAddress,
        })
      })

      const countdown = () => {
        if (this.locktimeLeft === 0) {
          return
        }
        window.setTimeout(() => {
          this.locktimeLeft--
          countdown()
        }, 1000)
      }
      this.locktimeLeft = 30
      countdown()
    }
  }
}
</script>

<style lang="scss" scoped>
.inner {
  font-size: 12px;
  margin-bottom: 10px;
  a {
    display: inline-block;
    border: 1px solid #ffffffc2;
    color: #ffffffc2;
    padding: .1em .5em;
    border-radius: .2em;
    text-decoration: none;
    margin-left: 1em;
    font-size: .8em;
    &.locked {
      opacity: .5;
    }
  }
}
</style>
