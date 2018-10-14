<template>
  <div class="center">

    <h2>Watch a new account</h2>

    <TokenPicker 
      v-if="!token"
      @change="token = $event"
    />

    <h3 v-if="token">
      {{ token.name }}
      <span>{{ token.ticker }}</span>
      <a @click="token = null">change</a>
    </h3>

    <template v-if="token && !address">

      <form @submit.prevent="pickAddress(inputAddress)">
        <input
          v-model="inputAddress"
          ref="address"
          placeholder="Enter an Ethereum address (0x...)"
        />
        <button type="submit" :class="{disabled: !isValid(inputAddress)}">
          Load address
        </button>
      </form>

      <TokenTopAccounts 
        :token="token"
        @change="pickAddress"
      />

    </template>

  </div>
</template>

<script>
import TokenPicker from '@/components/TokenPicker.vue'
import TokenTopAccounts from '@/components/TokenTopAccounts.vue'

export default {
  data () {
    return {
      token: null,
      address: null,
      inputAddress: '',
    }
  },
  components: {
    TokenPicker,
    TokenTopAccounts,
  },
  computed: {
    disabled () {
      return this.inputAddress.length !== 42
    }
  },
  methods: {
    isValid (address) {
      return address && address.length === 42 && address.match(/^0x/)
    },
    pickAddress (address) {
      if (!this.isValid(address)) {
        console.log('[%s] This address is not valid', address)
        return
      }
      this.$store.commit('WATCHLIST_ADD', {
        address,
        tokenAddress: this.token.address,
        txLoaded: null,
      })
      this.$store.dispatch('getTxs', {
        address,
        tokenAddress: this.token.address,
      })
      this.$router.push('/work/accounts')
    },
  },
  watch: {
    'token.address' (value) {
      if (value) {
        this.$nextTick(() => {
          this.$refs.address.focus()
        })
      }
    },
  }
}
</script>

<style lang="scss" scoped>
.center {
  text-align: center;
}
h2 {
  margin-top: 20px;
  margin-bottom: 40px;
}
h3 {
  margin-bottom: 15px;
  span {
    opacity: .5;
  }
  a {
    display: inline-block;
    margin-left: 10px;
    font-weight: normal;
    padding: 5px;
    font-size: 10px;
    cursor: pointer;
    text-decoration: underline;
    &:hover {
      color: #f6a622;
    }
  }
}
form {
  input {  
    text-align: center;
    font-size: 16px;
    font-family: 'Courier New', Courier, monospace;
    width: 430px;
  }
  button {
    background: transparent;
    border-radius: 2px;
    border: 1px solid #f6a622;
    color: #2c3e50;
    background: #f6a622;
    outline: none;
    cursor: pointer;
    font-size: 14px;
    margin-left: 15px;
    padding: 8px 16px;
    position: relative;
    top: 3px;
    &.disabled {
      color: #2c3e50;
      background: transparent;
      border-color: #2c3e50;
    }
  }
}
</style>
