<template>
  <div class="items">
    
    <div class="search">
      <i class="icon-search"/>
      <input 
        v-model="query"
        ref="query"
        placeholder="Search or select a token from the list below"
      />
    </div>

    <div 
      v-for="token in items"
      :key="token.address"
      @click="$emit('change', token)"
      class="item"
    >
      {{ token.name }}
      <span>{{ token.ticker }}</span>
    </div>

    <div v-if="items.length === 0" class="empty">
      No token matches your search
    </div>

  </div>
</template>

<script>
import { mapState } from 'vuex'

export default {
  data () {
    return {
      query: ''
    }
  },
  computed: {
    ...mapState(['tokens']),
    items () {
      return this.tokens.filter(token => {
        const regex = new RegExp(this.query, 'i')
        return token.name.match(regex) || token.ticker.match(regex)
      })
    }
  },
  mounted () {
    this.$refs.query.focus()
  },
}
</script>

<style lang="scss" scoped>
.items {
  margin: 20px auto 0;
  width: 400px;
}
.search {
  position: relative;
  i {
    position: absolute;
    opacity: .5;
    left: 3px;
    top: 7px;
    color: #2c3e50;
  }
  input {
    margin-bottom: 20px;
    width: 370px;
    font-size: 16px;
    padding: 10px 0 10px 30px;
  }
}
.item {
  padding: 5px;
  cursor: pointer;
  span {
    opacity: .5;
  }
  &:hover {
    color: #fff;
    background: #2c3e50;
  }
}
.empty {
  font-style: italic;
  padding: 20px 0;
}
</style>
