import Vue from 'vue'
import Vuex from 'vuex'

import store from 'store'

import tokens from '@/assets/tokens.json'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    tokens,
    watchList: store.get('watchList', []),
  },
  mutations: {
    WATCHLIST_ADD (state, payload) {
      if (state.watchList.find(i => i === payload)) {
        console.log('existe déja')
        return
      }
      state.watchList.push(payload)
      store.set('watchList', state.watchList)
    },
  },
  actions: {
  },
  getters: {
    getToken: (state) => (address) => {
      return state.tokens.find(token => token.address === address)
    }
  }
})
